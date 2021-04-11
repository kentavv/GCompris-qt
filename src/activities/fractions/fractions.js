/* GCompris - fractions.js
 *
 * Copyright (C) 2020 Johnny Jazeix <jazeix@gmail.com>
 *
 * SPDX-FileCopyrightText: Johnny Jazeix <jazeix@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
.pragma library
.import QtQuick 2.6 as Quick

var currentLevel = 0
var numberOfLevel
var levels
var items

function start(items_) {
    items = items_
    currentLevel = 0
    levels = items.levels
    numberOfLevel = levels.length
    initLevel()
}

function stop() {
}

function initLevel() {
    items.bar.level = currentLevel + 1

    items.pieSeries.clear();
    var size = 1./levels[currentLevel].denominator;
    for(var i = 0 ; i < levels[currentLevel].denominator ; ++ i) {
        items.pieSeries.append(1, size);
        items.pieSeries.setSliceStyle(items.pieSeries.count-1, false);
    }
}

function nextLevel() {
    if(numberOfLevel <= ++currentLevel) {
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
