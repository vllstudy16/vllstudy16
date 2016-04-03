$fs = 0.1; // smoothness of curves in render
$fa = 0.1;

/* Box */
{
    thickness = 2; //wall thickness
    extraThickness = 0.1; // required for proper rendering when $fs is large
    curve = 4; // curve on the edges of the box, must be > thickness
    internalDimensions = [65, 65, 30]; //internal dimensions
    externalDimensions = [internalDimensions[0] + (thickness * 2), internalDimensions[1] + (thickness * 2), internalDimensions[2] + (thickness * 2)];
    bottomHeight = 28; // height of the bottom half of the box
    topHeight = internalDimensions[2] - bottomHeight; // height of the top half of the box
    FR4Thickness = 1.7;
    overlap = 3;
}
//

cameraHolePos = [externalDimensions[0] / 2, externalDimensions[1] / 2];
ledHolePos = [externalDimensions[2] / 2, externalDimensions[1] - (externalDimensions[2] / 2)];
usbHolePos = [-0.01, 31.25 + curve, thickness + FR4Thickness];
sdHolePos = [-0.01, 6.5 + curve, thickness + FR4Thickness];
resetHolePos = [externalDimensions[2] / 2, externalDimensions[1] - (thickness / 2), externalDimensions[2] / 3];
powerHolePos = [externalDimensions[0] * ((sqrt(5) - 1) / 2), externalDimensions[1] - (thickness / 2) - 0.5, externalDimensions[2] / 3];
usbSize = [21.5, 36, 7.2];
sdSize = [25, 31, 3.55];
resetHoleSize = 6;
powerHoleSize = [6.5, thickness + extraThickness + 1, 3.5];
ledHoleRad = 2.5;
cameraHoleRad = 3.7;
cameraStandoffHeight = 4;

{
    /*
loc =   [
            [externalDimensions[0] + 3 , 0, 0],
            [externalDimensions[0] + 3 , 0, 22 + 5 + (thickness * 2)],
            [externalDimensions[0], 0, 22 + 5 + (thickness * 2)],
            [externalDimensions[0], 0, 22 + (thickness * 2)],
            [externalDimensions[0], 0, 22 + 5 + (thickness * 2)],
            [externalDimensions[0] + 3 , 0, 22 + 5 + (thickness * 2)],
            [externalDimensions[0] + 3 , 0, 0],
            [externalDimensions[0] + 3 , 0, 0]
        ];

function xyz(t,i) = 
    lookup(t, [
    [0/len(loc),loc[0][i]],
    [1/len(loc),loc[1][i]],
    [2/len(loc),loc[2][i]],
    [3/len(loc),loc[3][i]],
    [4/len(loc),loc[4][i]],
    [5/len(loc),loc[5][i]],
    [6/len(loc),loc[6][i]],
    [7/len(loc),loc[7][i]],

]);

loc2 =   [
            [0, 0, 0],
            [0, 0, 0],
            [0, -180, 0],
            [0, -180, 0],
            [0, -180, 0],
            [0, 0, 0],
            [0, 0, 0],
            [0, 0, 0]
        ];

function xyz2(t,i) = 
    lookup(t, [
    [0/len(loc2),loc2[0][i]],
    [1/len(loc2),loc2[1][i]],
    [2/len(loc2),loc2[2][i]],
    [3/len(loc2),loc2[3][i]],
    [4/len(loc2),loc2[4][i]],
    [5/len(loc2),loc2[5][i]],
    [6/len(loc2),loc2[6][i]],
    [7/len(loc2),loc2[7][i]],

]);

loc3 =   [
            [0, 0, 0],
            [0, 0, 90],
            [0, 0, 180],
            [0, 0, 270],
            [0, 0, 360],
            [0, 0, 180],
            [0, 0, 0],
            [0, 0, 0]
        ];

function xyz3(t,i) = 
    lookup(t, [
    [0/len(loc3),loc3[0][i]],
    [1/len(loc3),loc3[1][i]],
    [2/len(loc3),loc3[2][i]],
    [3/len(loc3),loc3[3][i]],
    [4/len(loc3),loc3[4][i]],
    [5/len(loc3),loc3[5][i]],
    [6/len(loc3),loc3[6][i]],
    [7/len(loc3),loc3[7][i]],

]);
*/
}
//

module cylinderHull(a, r)
{
    hull()
        {
            cylinder(r = r, h = a[2]);
            translate([a[0], 0, 0]) 
                cylinder(r = r, h = a[2]);
            translate([0, a[1], 0]) 
                cylinder(r = r, h = a[2]);
            translate([a[0], a[1], 0]) 
                cylinder(r = r, h = a[2]);
        }
}
//

module box(height, lip)
{
    // 0 = outer lip, 1 = inner lip
    translate([curve, curve, 0]) difference() 
    {
        union()
        {
            cylinderHull([externalDimensions[0] - (curve * 2), externalDimensions[1] - (curve * 2), height + thickness], curve);
            if(lip == 1)
            {
                translate([0, 0, thickness]) 
                    cylinderHull([externalDimensions[0] - (curve * 2), externalDimensions[1] - (curve * 2), height + overlap],curve - (thickness / 2));
            }
        }
        {
            translate([0, 0, thickness]) 
                cylinderHull([externalDimensions[0] - (curve * 2), externalDimensions[1] - (curve * 2), height + thickness + overlap], curve - thickness);
            if(lip == 0)
            {
                translate([0, 0, height + thickness - overlap]) 
                    cylinderHull([externalDimensions[0] - (curve * 2), externalDimensions[1] - (curve * 2), 0.01 + overlap], curve - (thickness / 2));
            }
        }
    }
}
//

module bottom(height)
{
    difference()
    {
        union()
        {
            box(height, 0);
            if(thickness < 3)
            {
                translate([externalDimensions[0] * ((sqrt(5) - 1) / 2) - 9.5, externalDimensions[1] - 3, thickness]) 
                cube([19, 3 - thickness, height - overlap]);//power switch extra thickness
            }
            translate([usbHolePos[0] + thickness, usbHolePos[1] - ((usbSize[0] - 11) / 2), thickness])
            {
                translate([2.6, usbSize[0] - 2.6, 0])
                {
                    cylinder(h = usbSize[2] - FR4Thickness, r = 2);
                    cylinder(h = usbSize[2], r = 1);
                }
                translate([2.6, 2.6, 0])
                {
                    cylinder(h = usbSize[2] - FR4Thickness, r = 2);
                    cylinder(h = usbSize[2], r = 1);
                }
                translate([usbSize[1] - 2.25, usbSize[0] - 2 - 2.25, 0])
                {
                    cylinder(h = usbSize[2] - FR4Thickness, r = 2);
                    cylinder(h = usbSize[2], r = 1);
                }
                translate([usbSize[1] - 2.25, 2 + 2.25, 0])
                {
                    cylinder(h = usbSize[2] - FR4Thickness, r = 2);
                    cylinder(h = usbSize[2], r = 1);
                }
            }
            translate([sdHolePos[0] + thickness, sdHolePos[1] - ((sdSize[0] - 14) / 2) - 1, thickness])
            {
                translate([2.575, sdSize[0] - 2.575, 0])
                    cylinder(h = FR4Thickness, r = 0.8);
                translate([2.575, 2.575, 0])
                    cylinder(h = FR4Thickness, r = 0.8);
                translate([sdSize[1] - 5.6 - 2.575, sdSize[0] - 2.575, 0])
                    cylinder(h = FR4Thickness, r = 0.8);
                translate([sdSize[1] - 5.6 - 2.575, 2.575, 0])
                    cylinder(h = FR4Thickness, r = 0.8);
            }
            translate([powerHolePos[0], powerHolePos[1], powerHolePos[2]])
            {
                translate([-7.5, 0, 0])
                    rotate([90, 0, 0])
                        cylinder(h = 3, r = 0.8);
                translate([7.5, 0, 0])
                    rotate([90, 0, 0])
                        cylinder(h = 3, r = 0.8);
            }
        }
        {
            translate([usbHolePos[0], usbHolePos[1], usbHolePos[2]]) 
                cube([thickness + extraThickness, 11, 6]);//usb hole
            translate([sdHolePos[0], sdHolePos[1], sdHolePos[2]]) 
                cube([thickness + extraThickness, 14, 4]);//sd hole
            translate([resetHolePos[0], resetHolePos[1], resetHolePos[2]]) 
                cube([resetHoleSize, thickness + extraThickness, resetHoleSize], center = true);//reset switch hole
            translate([powerHolePos[0], powerHolePos[1], powerHolePos[2]]) 
                cube([powerHoleSize[0], powerHoleSize[1], powerHoleSize[2]], center = true);//power switch hole
            hull () 
            {
                translate([sdHolePos[0], sdHolePos[1] + (thickness / 2), sdHolePos[2]]) sphere(r = thickness / 2, center = true);
                translate([sdHolePos[0], sdHolePos[1] + 14 - (thickness / 2), sdHolePos[2]]) sphere(r = thickness / 2, center = true);
            }
            hull () 
            {
                translate([sdHolePos[0], sdHolePos[1] + (thickness / 2), sdHolePos[2] + 4]) sphere(r = thickness / 2, center = true);
                translate([sdHolePos[0], sdHolePos[1] + 14 - (thickness / 2), sdHolePos[2] + 4]) sphere(r = thickness / 2, center = true);
            }
            translate([0, 61 + thickness, 15 + thickness])
                rotate([0, 90, 0])
                    cylinderHull([10, 0, thickness + extraThickness], 1);
            translate([0, 54 + thickness, 15 + thickness])
                rotate([0, 90, 0])
                    cylinderHull([10, 0, thickness + extraThickness], 1);
            translate([65 + thickness, 61 + thickness, 15 + thickness])
                rotate([0, 90, 0])
                    cylinderHull([10, 0, thickness + extraThickness], 1);
            translate([65 + thickness, 54 + thickness, 15 + thickness])
                rotate([0, 90, 0])
                    cylinderHull([10, 0, thickness + extraThickness], 1);
            translate([usbHolePos[0] + thickness, usbHolePos[1] - ((usbSize[0] - 11) / 2), 0])
            {
                translate([7, usbSize[0] - 2.6, 0])
                {
                    cylinder(h = usbSize[2], r = 1.5);
                }
                translate([7, 2.6, 0])
                {
                    cylinder(h = usbSize[2], r = 1.5);
                }
                translate([usbSize[1] - 2.25, usbSize[0] - 2 - 2.25 + 4, 0])
                {
                    cylinder(h = usbSize[2], r = 1.5);
                }
            }
        }
    }
}
//

module top(height)
{
    difference()
    {
        union()
        {
            box(height, 1);
            translate([cameraHolePos[0], cameraHolePos[1], thickness]) 
            {
                translate([-8.5, 19.9, 0])// Top L
                {
                    cylinder(h = cameraStandoffHeight, r = 1.5);
                    cylinder(h = cameraStandoffHeight + FR4Thickness, r = 0.6);
                }
                translate([8.5, 19.9, 0])// Top R
                {
                    cylinder(h = cameraStandoffHeight, r = 1.5);
                    cylinder(h = cameraStandoffHeight + FR4Thickness, r = 0.6);
                }
                translate([-8.5, -5.5, 0])// Bottom L
                {
                    cylinder(h = cameraStandoffHeight, r = 1.5);
                    cylinder(h = cameraStandoffHeight + FR4Thickness, r = 0.6);
                }
                translate([8.5, -5.5, 0])// Bottom R
                {
                    cylinder(h = cameraStandoffHeight, r = 1.5);
                    cylinder(h = cameraStandoffHeight + FR4Thickness, r = 0.6);
                }
            }
        }
        {
            translate([cameraHolePos[0], cameraHolePos[1], -0.01]) 
                cylinder(r = cameraHoleRad, h = thickness + extraThickness);//camera hole
            translate([ledHolePos[0], ledHolePos[1], -0.01])
                cylinder(r = ledHoleRad, h = thickness + extraThickness);//led hole
        }
    }
}
//

//bottom(bottomHeight);

top(topHeight);

//translate([externalDimensions[0], 0, 22 + 2 + (thickness * 2)]) rotate([0,180,0]) top(topHeight);

//translate([xyz($t,0),xyz($t,1),xyz($t,2)]) rotate([xyz2($t,0),xyz2($t,1),xyz2($t,2)]) top(topHeight);
    
//translate([2, 4, 3]) cube([31, 25, 3.55]);//sd
//translate([2, 30, 3]) cube([36, 21.5, 7.2]);//usb
