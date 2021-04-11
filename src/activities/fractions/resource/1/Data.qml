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
        {
            "numerator": 3,
            "denominator": 6,
            "instruction": qsTr("Select half of the pie.")
        }
    ]
}
