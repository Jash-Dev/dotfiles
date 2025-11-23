import QtQuick

Item {
    id: calendar
    // parent controls size; we'll just fill it
    anchors.fill: parent

    property date today: new Date()
    property int currentMonth: today.getMonth()
    property int currentYear: today.getFullYear()

    Column {
        anchors {
            fill: parent
            leftMargin: 14
            rightMargin: 14
            topMargin: 12
            bottomMargin: 14
        }
        spacing: 10

        // Month header
        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 18
            font.bold: true
            color: "white"

            text: {
                const names = ["January","February","March","April","May","June",
                               "July","August","September","October","November","December"]
                names[currentMonth] + " " + currentYear
            }
        }

        // Weekday headers
        Grid {
            width: parent.width
            columns: 7
            columnSpacing: 6
            rowSpacing: 4

            Repeater {
                model: ["Su","Mo","Tu","We","Th","Fr","Sa"]

                Text {
                    text: modelData
                    font.pixelSize: 11
                    color: "#cccccc"
                    width: (parent.width - (6 * 6)) / 7
                    height: 20
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        // Date grid
        Grid {
            id: dateGrid
            width: parent.width
            columns: 7
            columnSpacing: 6
            rowSpacing: 6

            property var firstDay: new Date(calendar.currentYear, calendar.currentMonth, 1)
            property int startOffset: firstDay.getDay()
            property int daysInMonth: new Date(calendar.currentYear,
                                               calendar.currentMonth + 1, 0).getDate()

            // 42 cells = 6 weeks
            Repeater {
                model: 42

                Rectangle {
                    width: (parent.width - (6 * 6)) / 7
                    height: 34
                    radius: 6

                    property int nthDay: index - dateGrid.startOffset + 1
                    property bool isValid: nthDay >= 1 && nthDay <= dateGrid.daysInMonth

                    property bool isToday: {
                        if (!isValid) return false
                        const now = new Date()
                        return (
                            nthDay === now.getDate() &&
                            calendar.currentMonth === now.getMonth() &&
                            calendar.currentYear === now.getFullYear()
                        )
                    }

                    color: isToday ? "#3A78FF" : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: parent.isValid ? parent.nthDay : ""
                        font.pixelSize: 13
                        color: parent.isToday ? "white"
                              : parent.isValid ? "white"
                              : "#666666"
                        font.bold: parent.isToday
                    }
                }
            }
        }

        // Upcoming events placeholder (we’ll hook gcal here later)
        Column {
            spacing: 4
            width: parent.width

            Text {
                text: "Upcoming events"
                font.pixelSize: 14
                font.bold: true
                color: "white"
            }

            Text {
                text: "• No events (yet)"
                font.pixelSize: 12
                color: "#cccccc"
                elide: Text.ElideRight
            }
        }
    }
}

