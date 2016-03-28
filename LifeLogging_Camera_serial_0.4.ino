#include <Adafruit_VC0706.h>
#include <SPI.h>
#include <SD.h>
#include <SoftwareSerial.h>
#include <TimerOne.h>
#include <Wire.h>
#include <RTClib.h>
#include <EEPROM.h>

#define chipSelect 10
#define cameraTX 3
#define cameraRX 4
#define switchPin 2
#define ledPin 5

//ms betwen photos
#define photoDelayLength 300000 //15 min
//length in us of flashes
#define flashLength 500000 //0.5 sec
//minimum length of on period (length of time on / length of flash)
#define onPeriodMin 10 //5 sec
//maximum length of on period (length of time on / length of flash)
#define onPeriodMax 10 //5 sec
//minimum length of off period in sec
#define offPeriodMin 900 //15 min
//maximum length of off period in sec
#define offPeriodMax 900 //15 min
//amount of time to delete when button is pressed in sec
#define deleteLength 335 //5 min + extra to make sure last photo deleted

SoftwareSerial cameraconnection = SoftwareSerial(cameraTX, cameraRX);
Adafruit_VC0706 cam = Adafruit_VC0706(&cameraconnection);

RTC_DS1307 rtc;

boolean deletePhotoToggle = false;
boolean flashStartToggle = false;
boolean flashEndToggle = false;
boolean flash = false;
char dirName[10] = {"/00000000"};
uint32_t offRandom = 30; //start flashing after 30 sec
uint16_t onRandom = 0;
DateTime flashStart;
DateTime flashEnd;

void setup()
{
	randomSeed(analogRead(0));

	pinMode(ledPin, OUTPUT);
	PORTD |= (1 << ledPin); //set ledPin high
  
	pinMode(switchPin, INPUT);

	Serial.begin(9600);
	Wire.begin();
  rtc.begin();
	
	Serial.println(F("-----------------------"));
	Serial.println(F("LifeLogging Camera"));
	Serial.println(F("-----------------------"));
	Serial.println();

	if (EEPROM.read(0) == 0)
	{
		flash = false;
	}
	else
	{
		flash = true;
	}

	if (digitalRead(switchPin) == HIGH)
	{
		flash = !flash;
		EEPROM.write(0, flash);

		Serial.print(F("Flashing "));
		Serial.println(flash);
		Serial.println();
	}
  
	// see if the card is present and can be initialized:
	if (!SD.begin(chipSelect))
	{
		Serial.println(F("Card failed, or not present"));
		while(1);
	}
	
	// Try to locate the camera
	if (!cam.begin())
	{
		Serial.println(F("No camera found?"));
		while(1);
	}

	if (!rtc.begin())
	{
		Serial.println(F("RTC is not running"));
		while (1);
	}

	//rtc.adjust(DateTime(__DATE__, __TIME__));
  DateTime now = rtc.now();
  Serial.println(now.year());

	if (now.year() == 2165)
	{
		Serial.println(F("RTC communication error"));
		while (1);
	}

	// Set the picture size - 640x480
	cam.setImageSize(VC0706_640x480);

	if (flash == false)
	{
		delay(500);
		PORTD &= ~(1 << ledPin); //set ledPin low
		delay(500);
		PORTD |= (1 << ledPin); //set ledPin high
		delay(500);
	}
	else
	{
		offRandom += now.unixtime();

		Timer1.initialize(flashLength);

		delay(500); //gives components time to start
	}

	PORTD &= ~(1 << ledPin); //set ledPin low

	attachInterrupt(0, deletePhotos, FALLING);
}

void loop()
{
	int32_t timeElapsed =  millis();
	Serial.flush();
	dirGen();
	if (flash == true)
	{
		blinkGenerator();
	}
	takePhoto(timeElapsed);
	deleteBuffer();
	if (flash == true)
	{
		storeFlashTime();
	}

	while((millis() - timeElapsed) < photoDelayLength);
}

void takePhoto(int32_t timeElapsed)
{
	uint32_t timeDifference = 0;
	char charBuff[23];
	strlcpy(charBuff, fileNameGen(rtc.now()), sizeof(charBuff));

	if (!cam.takePicture())
	{
		Serial.println(F("Failed to take photo"));
		return;
	}
	else
	{
		Serial.println(F("Picture taken"));
	}
		
	if (SD.exists(charBuff))
	{
		Serial.println(F("Overwriting"));
	}

	// Open the file for writing
	File imgFile = SD.open(charBuff, FILE_WRITE);

	// Get the size of the image (frame) taken  
	uint16_t jpglen = cam.frameLength();
	Serial.print(F("Writing image to "));
	Serial.println(charBuff);
	Serial.print(F("Storing "));
	Serial.print(jpglen, DEC);
	Serial.print(F(" byte image."));

	pinMode(8, OUTPUT);
	// Read all the data up to # bytes!
	byte wCount = 0; // For counting # of writes
	while (jpglen > 0)
	{
		// read 32 bytes at a time;
		uint8_t *buffer;
		uint8_t bytesToRead = min(64, jpglen); // change 64 to 32 if storing photos proves unstable
		buffer = cam.readPicture(bytesToRead);
		imgFile.write(buffer, bytesToRead);
		if (++wCount >= 64)
		{
			//Every 2K, give a little feedback so it doesn't appear locked up
			Serial.print('.');
			wCount = 0;
		}
		jpglen -= bytesToRead;
	}
	imgFile.close();

	timeDifference = millis() - timeElapsed;
	Serial.println(F("done!"));
	Serial.print(timeDifference);
	Serial.println(F(" ms elapsed"));
	Serial.println();
	cam.resumeVideo();
}

void logInitialization(char logName[], char title[])
{
	File logFile = SD.open(logName, FILE_WRITE);
	delay(10);
	/*
	logFile.println(F("-------------------------"));
	logFile.println(F("LifeLogging Camera"));
	logFile.print(title);
	logFile.print(F(" Log file "));
	logFile.print(dirName);
	logFile.println();
	logFile.println(F("-------------------------"));
	*/
	logFile.close();
}

void storeFlashTime()
{
	if ((flashStartToggle * flashEndToggle) == true)
	{
		Serial.println(F("Updating fla_log.txt"));
		char charBuff[23];

		strlcpy(charBuff, dirName, sizeof(charBuff));
		strcat(charBuff, "/fla_log.txt");
		File flashLog = SD.open(charBuff, FILE_WRITE);
		strcpy(charBuff, timeNameGen(flashStart));
		flashLog.print(charBuff);
		flashLog.print(F("		"));
		strcpy(charBuff, timeNameGen(flashEnd));
		flashLog.println(charBuff);
		flashLog.close();

		flashStartToggle = false;
		flashEndToggle = false;
	}
}

void blinkLED()
{
	if (digitalRead(ledPin) == HIGH)
	{
		PORTD &= ~(1 << ledPin); //set ledPin low
	}
	else
	{
		PORTD |= (1 << ledPin); //set ledPin high
	}
	--onRandom;
	if (onRandom == 0)
	{
		flashEndToggle = true;
		PORTD &= ~(1 << ledPin); //set ledPin low
		Timer1.detachInterrupt();
	}
}

void blinkGenerator()
{
	if ((flashStartToggle + flashEndToggle) == 0)
	{
		uint16_t onRandomTemp = onRandom;
		DateTime timeTemp = rtc.now();

		if (onRandomTemp == 0)
		{	
			if (offRandom == 0)
			{
				offRandom = random(offPeriodMin, (offPeriodMax + 1));
				offRandom += timeTemp.unixtime();
			}
			if (offRandom <= timeTemp.unixtime())
			{
				flashStart = timeTemp;
				flashStartToggle = true;
				onRandomTemp = random(onPeriodMin, (onPeriodMax + 1));
				flashEnd = ((onRandomTemp * flashLength) / 1000000) + timeTemp.unixtime();
				offRandom = 0;
				noInterrupts();
				onRandom = onRandomTemp;
				Timer1.attachInterrupt(blinkLED);
				interrupts();
			}
		}
	}
}

void deletePhotos()
{
	deletePhotoToggle = true;
	detachInterrupt(0);
}

void deleteBuffer()
{
	noInterrupts();
	boolean deletePhotoToggleTemp = deletePhotoToggle;
	interrupts();

	if (deletePhotoToggleTemp == true)
	{
		DateTime now = rtc.now();
		uint32_t startTime = now.unixtime();
		char charBuff[23];

		Serial.println(F("Updating del_log.txt"));
		strlcpy(charBuff, dirName, sizeof(charBuff));
		strcat(charBuff, "/del_log.txt");
		File deleteLog = SD.open(charBuff, FILE_WRITE);
		uint32_t x = 0;
		if (startTime > deleteLength)
		{
			x = (startTime - deleteLength);
		}

		while (x < startTime)
		{
			now = x;
			strlcpy(charBuff, fileNameGen(now), sizeof(charBuff));
			if (SD.exists(charBuff))
			{
				Serial.print(F("Deleting "));
				Serial.println(charBuff);
				SD.remove(charBuff);
				deleteLog.println(now.unixtime());
				//deleteLog.println(charBuff);
			}
			++x;
		}
		deleteLog.close();
		deletePhotoToggleTemp = false;
		noInterrupts();
		deletePhotoToggle = false;
		interrupts();
		attachInterrupt(0, deletePhotos, FALLING);
	}
}

char* fileNameGen(DateTime time)
{
	char charBuff[23];
	strlcpy(charBuff, dirName, sizeof(charBuff));
	strcat(charBuff, "/");
	strcat(charBuff, timeNameGen(time));
	strcat(charBuff, ".JPG");
	return charBuff;
}

char* timeNameGen(DateTime time)
{
	char charBuff[9];
	char charShort[3];

	sprintf(charShort, "%d", time.hour());
	if (time.hour() < 10)
	{
		strlcpy(charBuff, "0", sizeof(charBuff));
		strcat(charBuff, charShort);
	}
	else
	{
		strlcpy(charBuff, charShort, sizeof(charBuff));
	}

	strcat(charBuff, "_");

	sprintf(charShort, "%d", time.minute());
	if (time.minute() < 10)
	{
		strcat(charBuff, "0");
		strcat(charBuff, charShort);
	}
	else
	{
		strcat(charBuff, charShort);
	}

	strcat(charBuff, "_");

	sprintf(charShort, "%d", time.second());
	if (time.second() < 10)
	{
		strcat(charBuff, "0");
		strcat(charBuff, charShort);
	}
	else
	{
		strcat(charBuff, charShort);
	}

	return charBuff;
}

char* dateNameGen(DateTime now)
{
	char charBuff[10] = {"\0"};
	char charShort[5];
	strlcpy(charBuff, "/", sizeof(charBuff));

	sprintf(charShort, "%d", now.year());
	if (now.year() < 10)
	{
		strcat(charBuff, "000");
		strcat(charBuff, charShort);
	}
	else if (now.year() < 100)
	{
		strcat(charBuff, "00");
		strcat(charBuff, charShort);
	}
	else if (now.year() < 1000)
	{
		strcat(charBuff, "0");
		strcat(charBuff, charShort);
	}
	else
	{
		strcat(charBuff, charShort);
	}

	sprintf(charShort, "%d", now.month());
	if (now.month() < 10)
	{
		strcat(charBuff, "0");
		strcat(charBuff, charShort);
	}
	else
	{
		strcat(charBuff, charShort);
	}

	sprintf(charShort, "%d", now.day());
	if (now.day() < 10)
	{
		strcat(charBuff, "0");
		strcat(charBuff, charShort);
	}
	else
	{
		strcat(charBuff, charShort);
	}

	return charBuff;
}

void dirGen()
{
	char charBuff[23];
	strlcpy(charBuff, dateNameGen(rtc.now()), sizeof(charBuff));
	if (dirName != charBuff)
	{
		strlcpy(dirName, charBuff, sizeof(dirName));
		if (!SD.exists(dirName))
		{
			SD.mkdir(dirName);
			strlcpy(charBuff, dirName, sizeof(charBuff));
			strcat(charBuff, "/del_log.txt");
			logInitialization(charBuff, "Deleted Files");
			strlcpy(charBuff, dirName, sizeof(charBuff));
			strcat(charBuff, "/fla_log.txt");
			logInitialization(charBuff, "Flash Timings");
			/*
			File flashLog = SD.open(charBuff, FILE_WRITE);
			delay(10);
			flashLog.println(F("ON\t\t\t\t\tOFF"));
			flashLog.close();
			*/
		}
	}
}
