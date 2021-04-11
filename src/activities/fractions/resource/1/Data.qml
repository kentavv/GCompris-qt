/* GCompris - Data.qml
 *
 * SPDX-FileCopyrightText: 2021 Johnny Jazeix <jazeix@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import GCompris 1.0

Data {
    objective: qsTr("Find the value.")
    difficulty: 3

    data: [
        {
            "numerator": 1,
            "denominator": 2,
            "instruction": qsTr("Select half of the pie.")
        },
        {
            "numerator": 1,
            "denominator": 3,
            "instruction": qsTr("Select a third of the pie.")
        },
        {
            "numerator": 2,
            "denominator": 3,
            "instruction": qsTr("Select two thirds of the pie.")
        },
        {
            "numerator": 1,
            "denominator": 4,
            "instruction": qsTr("Select a quarter of the pie.")
        },
        // second dataset with multipliers
        {
            "numerator": 3,
            "denominator": 6,
            "instruction": qsTr("Select half of the pie.")
        },
        // third dataset with percentage (maybe specific activity?)
        {
            "numerator": 1,
            "denominator": 2,
            "instruction": qsTr("Select 50% of the pie.")
        },
        {
            "numerator": 3,
            "denominator": 10,
            "instruction": qsTr("Select 30% of the pie.")
        },
        {
            "numerator": 9,
            "denominator": 12,
            "instruction": qsTr("Select 75% of the pie.")
        },
        // fourth dataset with questions?
        {
            "numerator": 3,
            "denominator": 7,
            "instruction": qsTr("Select the closest number of parts of the pie to the half but less than the half.")
        }
    ]
}
