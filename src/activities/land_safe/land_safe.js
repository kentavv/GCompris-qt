/* GCompris - land_safe.js
 *
 * Copyright (C) 2016 Holger Kaelberer <holger.k@elberer.de>
 *
 * Authors:
 *   Matilda Bernard <serah4291@gmail.com> (GTK+ version)
 *   Holger Kaelberer <holger.k@elberer.de> (Qt Quick port)
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program; if not, see <http://www.gnu.org/licenses/>.
 */

/* ToDo:
 * (- zoom out if too high!)
 * - check for shader availability
 * (- use polygon fixture for rocket)
 * (- improve graphics of velocity etc.)
 * - build/activate conditionally (box2d)
 *
 * Some gravitational forces:
 * !- Pluto: 0,62 m/s²
 * - Titan: 1,352 m/s²
 * !- Moon: 1,622 m/s²
 * - Io: 1,796 m/s²
 * !- Mars: 3,711 m/s²
 * - Merkur: 3,7 m/s²
 * !- Venus: 8,87 m/s²
 * - Earth: 9,807 m/s²
 * - Jupiter: 24,79 m/s²
 */

.pragma library
.import QtQuick 2.0 as Quick
.import GCompris 1.0 as GCompris

var levels = [
                                /**  simple  **/
            {   "planet": "Pluto",  "gravity": 0.62,    "maxAccel": 0.2,
                "accelSteps": 3,    "alt": 100.0,       "mode": "simple",
                "fuel" : 5 },
            {   "planet": "Moon",   "gravity": 1.62,    "maxAccel": 0.4,
                "accelSteps": 4,    "alt": 150.0,       "mode": "simple",
                "fuel" : 10 },
            {   "planet": "Mars",   "gravity": 3.71,    "maxAccel": 0.6,
                "accelSteps": 5,    "alt": 200.0,       "mode": "simple",
                "fuel" : 20 },
            {   "planet": "Vulc@n", "gravity": 5.55,    "maxAccel": 1.0,
                "accelSteps": 5,    "alt": 300.0,       "mode": "simple",
                "fuel" : 30 },
            {   "planet": "Venus",  "gravity": 8.87,    "maxAccel": 1.2,
                "accelSteps": 5,    "alt": 300.0,       "mode": "simple",
                "fuel" : 70 },

                                /**  rotation  **/
            {   "planet": "Pluto",  "gravity": 0.62,    "maxAccel": 0.2,
                "accelSteps": 3,    "alt": 100.0,       "mode": "rotation",
                "fuel" : 5 },
            {   "planet": "Moon",   "gravity": 1.62,    "maxAccel": 0.4,
                "accelSteps": 4,    "alt": 150.0,       "mode": "rotation",
                "fuel" : 10 },
            {   "planet": "Mars",   "gravity": 3.71,    "maxAccel": 0.6,
                "accelSteps": 5,    "alt": 200.0,       "mode": "rotation",
                "fuel" : 20 },
            {   "planet": "Vulc@n", "gravity": 5.55,    "maxAccel": 1.0,
                "accelSteps": 5,    "alt": 300.0,       "mode": "rotation",
                "fuel" : 30 },
            {   "planet": "Venus",  "gravity": 8.87,    "maxAccel": 1.2,
                "accelSteps": 5,    "alt": 300.0,       "mode": "rotation",
                "fuel" : 70 }
];

var introTextSimple = qsTr("Use the up and down keys to control the thrust."
                           + "<br/>Use the right and left keys to control direction."
                           + "<br/>You must drive Tux's ship towards the landing platform."
                           + "<br/>The landing platform turns green when the velocity is safe to land.")

var introTextRotate = qsTr("The up and down keys control the thrust of the rear engine."
                           + "<br/>The right and left keys now control the rotation of the ship."
                           + "<br/>To move the ship in horizontal direction you must first rotate and then accelerate it.")

var currentLevel = 0;
var numberOfLevel;
var items = null;
var baseUrl = "qrc:/gcompris/src/activities/land_safe/resource";
var startingHeightReal = 100.0;
var startingOffsetPx = 10;  // y-value for setting rocket initially
var gravity = 1;
var maxLandingVelocity = 10;
var leftRightAccel = 0.1;   // accel force set on horizontal accel
//var minAccel = 0.1;
var maxAccel = 0.15;
var accelSteps = 3;
var dAccel = maxAccel / accelSteps;//- minAccel;
var barAtStart;
var maxFuel = 100.0;
var currentFuel = 0.0;
var lastLevel = -1;
var debugDraw = false;

function start(items_) {
    items = items_;
    currentLevel = 0;
    numberOfLevel = levels.length;
    barAtStart = GCompris.ApplicationSettings.isBarHidden;
    GCompris.ApplicationSettings.isBarHidden = true;
    initLevel()
}

function stop() {
    GCompris.ApplicationSettings.isBarHidden = barAtStart;
}

function initLevel() {
    if (items === null)
        return;

    items.bar.level = currentLevel + 1

    var max = items.background.width - items.landing.width-20;
    var min = 20;
    items.rocket.explosion.hide();
    items.rocket.x = Math.random() * (max- min) + min;
    items.rocket.y = startingOffsetPx;
    items.rocket.rotation = 0;
    items.rocket.accel = 0;
    items.rocket.leftAccel = 0;
    items.rocket.rightAccel = 0;
    items.rocket.body.linearVelocity = Qt.point(0,0)
    items.landing.anchors.leftMargin = Math.random() * (max- min) + min;

    maxAccel = levels[currentLevel].maxAccel;
    accelSteps = levels[currentLevel].accelSteps;
    dAccel = maxAccel / accelSteps;//- minAccel;
    startingHeightReal = levels[currentLevel].alt;
    gravity = levels[currentLevel].gravity;
    items.mode = levels[currentLevel].mode;
    maxFuel = currentFuel = levels[currentLevel].fuel;

    items.world.pixelsPerMeter = getHeightPx() / startingHeightReal;
    items.world.gravity = Qt.point(0, gravity)
    items.world.running = false;
    items.landing.source = baseUrl + "/landing_green.png";

    console.log("Starting level (surfaceOff=" + items.ground.surfaceOffset + ", ppm=" + items.world.pixelsPerMeter + ")");

    if (currentLevel === 0 && lastLevel !== 0) {
        items.ok.visible = false;
        items.intro.intro = [introTextSimple];
        items.intro.index = 0;
    } else if (currentLevel === 5 && lastLevel !== 0) {
        items.ok.visible = false;
        items.intro.intro = [introTextRotate];
        items.intro.index = 0;
    } else {
        // go
        items.intro.index = -1;
        items.ok.visible = true;
    }
    lastLevel = currentLevel;
}

function getHeightPx()
{
    var heightPx = items.background.height - items.ground.height + items.ground.surfaceOffset
            - items.rocket.y - items.rocket.height
            - 1;  // landing is 1 pixel above ground surface
    return heightPx;
}

// calc real height of rocket in meters above surface
function getRealHeight()
{
    var heightPx = getHeightPx();
    var heightReal = heightPx / items.world.pixelsPerMeter;
    return heightReal;
}

function nextLevel() {
    if(numberOfLevel <= ++currentLevel ) {
        currentLevel = 0
    }
    initLevel();
}

function previousLevel() {
    if(--currentLevel < 0) {
        currentLevel = numberOfLevel - 1
    }
    initLevel();
}

function processKeyPress(event)
{
    var key = event.key;
    event.accepted = true;
    var newAccel = 0;
    if (key === Qt.Key_Up || key === Qt.Key_Down) {
        if (key === Qt.Key_Up) {
            if (items.rocket.accel === 0)
                newAccel = dAccel;
            else
                newAccel = items.rocket.accel + dAccel;
        } else if (key === Qt.Key_Down)
            newAccel = items.rocket.accel - dAccel;

        if (newAccel < dAccel)
            newAccel = 0;
        if (newAccel > maxAccel)
            newAccel = maxAccel;

        if (newAccel !== items.rocket.accel && currentFuel > 0)
            items.rocket.accel = newAccel;
    } else if (key === Qt.Key_Right || key === Qt.Key_Left) {
        if (items.mode === "simple") {
            if (key === Qt.Key_Right && !event.isAutoRepeat && currentFuel > 0) {
                items.rocket.leftAccel = leftRightAccel;
                items.rocket.rightAccel = 0.0;
            } else if (key === Qt.Key_Left && !event.isAutoRepeat && currentFuel > 0) {
                items.rocket.rightAccel = leftRightAccel;
                items.rocket.leftAccel = 0.0;
            }
        } else { // "rotation"
            if (key === Qt.Key_Right)
                items.rocket.rotation += 10;
            else if (key === Qt.Key_Left)
                items.rocket.rotation -= 10;
            //console.log("XXX rotation=" + items.rocket.rotation + " bodyRot=" + items.rocket.body.rotation);
        }
    } else
        event.accepted = false;
}

function processKeyRelease(event)
{
    var key = event.key;
    event.accepted = true;
    //console.log("XXX release " + key + " = " + event.isAutoRepeat + " = " + Qt.Key_Right);
    if (key===Qt.Key_1) {
        items.rocket.explosion.show();
    }
    if (key===Qt.Key_0) {
        items.rocket.explosion.hide();
    }

    if (key === Qt.Key_Right && !event.isAutoRepeat) {
        items.rocket.leftAccel = 0;
    } else if (key === Qt.Key_Left && !event.isAutoRepeat) {
        items.rocket.rightAccel = 0;
    } else
        event.accepted = false;
}

function finishLevel(success)
{
    items.rocket.accel = 0;
    items.rocket.leftAccel = 0;
    items.rocket.rightAccel = 0;
    items.rocket.body.linearVelocity = Qt.point(0,0)
    if (success)
        items.bonus.good("lion");
    else {
        items.rocket.explosion.show();
        items.bonus.bad("lion");
    }
}

function degToRad(degrees) {
  return degrees * Math.PI / 180;
}
