/*
 * Copyright (C) 2020  Hendrik Scheewel
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * OpenVelo is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components 1.3 as UbuntuComponents
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3

import QtLocation 5.3
import QtPositioning 5.6
import Ubuntu.DownloadManager 1.2
import QtQuick.Controls.Suru 2.2

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'openvelo.hendrikscheewel'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    Plugin {
    id: mapPlugin
    name: "osm"
    }

    property var network_ID : settings.network_ID;
    property var networkCenter: settings.networkCenter;
    property var favoriteStations: settings.favoriteStations;
    property var currentLoc: QtPositioning.coordinate(networkCenter["latitude"], networkCenter["longitude"]);
    property var currentDir: 0;
    property var locationFix: false;

        StackLayout {
            id: stackview
            anchors.fill : parent

            Page {
                anchors.fill: parent

                header: PageHeader {

                    title: i18n.tr('Map')

                    trailingActionBar.actions: [
                    Action {
                        iconName: 'reload'
                        text: i18n.tr('Reload from Server');
                        onTriggered: python.loadFromServer();
                    },
                    Action {
                        iconName: 'view-list-symbolic'
                        text: i18n.tr('Update Location')
                        onTriggered: stackview.currentIndex = 1;
                    },
                    Action {
                        iconName: 'stock_website'
                        text: i18n.tr('Select network')
                        onTriggered: stackview.currentIndex = 2;
                    },
                    Action {
                        iconName: 'info'
                        text: i18n.tr('Info')
                        onTriggered: stackview.currentIndex = 3;
                    }
                    ]
                }


    Map {
        id: map
        anchors.fill: parent
        plugin: mapPlugin
        zoomLevel: 13
        center: QtPositioning.coordinate(networkCenter["latitude"], networkCenter["longitude"]);

        ListModel {
            id: veloModel
            ListElement {
                  empty_slots: 0
                  free_bikes: 0
                  station_ID: ""
                  latitude: 0
                  longitude: 0
                  name: ""
                  hours_since_update: 0
                  minutes_since_update: 0
                  bg: ""
            }
            }

          MapItemView {
              model: veloModel
              delegate: MapQuickItem {
                  coordinate: QtPositioning.coordinate(latitude, longitude)
                  zoomLevel: if (map.zoomLevel <  16) {16} else {0}

                  sourceItem:Item {
                    Rectangle{
                      width: units.gu(2*6);
                      height: width;
                      radius: width/2;
                      anchors.bottom: parent.verticalCenter;
                      anchors.left: parent.horizontalCenter;
                      border.color:"#FFFFFF";
                      border.width:2;
                      transformOrigin: Item.BottomLeft;
                      rotation: -45; }

                    Rectangle{width: units.gu(1.1*6);
                     height: width;
                     radius: width/20;
                     anchors.bottom: parent.verticalCenter;
                     anchors.left: parent.horizontalCenter;
                     border.color:"#FFFFFF"; border.width:2;
                     transformOrigin: Item.BottomLeft;
                     rotation: -45; }

                     Rectangle{
                       width: units.gu(1.1*6);
                       height: width;
                       radius: width/20;
                       anchors.bottom: parent.verticalCenter;
                       anchors.left: parent.horizontalCenter;
                       color: bg;
                       transformOrigin: Item.BottomLeft;
                       rotation: -45;
                     }

                     Rectangle{
                       id: innerCircle
                       width: units.gu(2*6);
                       height: width;
                       radius: width/2;
                       anchors.bottom: parent.verticalCenter;
                       anchors.left: parent.horizontalCenter;
                       color:bg;
                       transformOrigin: Item.BottomLeft;
                       rotation: -45;

                    Item{
                      rotation: 45;
                      anchors.centerIn: parent;

                    Column{
                      anchors.centerIn: parent;
                    Text{
                      anchors.horizontalCenter: parent.horizontalCenter;
                      color: "white";
                      horizontalAlignment: Text.AlignHCenter;
                      text: name//.slice(0, 12);
                      wrapMode: Text.Wrap
                      maximumLineCount: 2
                      font.pointSize: units.gu(1)
                      width: 0.8*innerCircle.width
                    }
                    /*Text{
                      width: 0.8*innerCircle.width
                      maximumLineCount: 2
                      anchors.horizontalCenter: parent.horizontalCenter;
                      color: "white";
                      horizontalAlignment: Text.AlignHCenter;
                      text: name.split(' - ')[0]//.slice(0, 12) + '...';
                      wrapMode: Text.Wrap
                      font.pointSize: 20
                  }*/
                    Row {
                      id: busyBar
                      anchors.horizontalCenter: parent.horizontalCenter;
                      Text {
                          color: "#CCCCCC";
                          text: free_bikes + ' ';
                          horizontalAlignment: Text.AlignRight;
                          font.pointSize: units.gu(1)
                      }
                      Rectangle {
                        id: bikeBar
                        width: 0.5*innerCircle.width*free_bikes/(free_bikes+empty_slots);
                        height: 0.1*innerCircle.width;
                        color: "#444444";
                      }
                      Rectangle {
                        id: standsBar
                        width: 0.5*innerCircle.width*empty_slots/(free_bikes+empty_slots);
                        height: 0.1*innerCircle.width;
                        color: "#CCCCCC";
                      }
                      Text {
                          color: "#CCCCCC";
                          text: ' ' + empty_slots;
                          horizontalAlignment: Text.AlignLeft;
                          font.pointSize: units.gu(1)
                      }
                    }
                    Row {
                      id: barLabels
                      width : busyBar.width
                      anchors.horizontalCenter: parent.horizontalCenter;

                      Text {
                          id: bikesLabel
                          color: "#CCCCCC";
                          font.pointSize: units.gu(1)
                          text: i18n.tr("Bikes");
                          Layout.fillHeight: true
                          Layout.alignment: Qt.AlignLeft
                          horizontalAlignment: Text.AlignLeft;
                      }

                      Item {
                          width: barLabels.width-bikesLabel.contentWidth-standsLabel.contentWidth;
                          height: 10
                          Layout.fillWidth: true
                          Layout.alignment: Qt.AlignHCenter
                      }
                      Text {
                          id: standsLabel
                          color: "#CCCCCC";
                          font.pointSize: units.gu(1)
                          text: i18n.tr("Stands");
                          Layout.fillHeight: true
                          Layout.alignment: Qt.AlignRight
                          horizontalAlignment: Text.AlignRight;
                      }

                    }
                    }


                    }
                    }

              }
              }
          }

          MapQuickItem{
            id: point;
            coordinate : root.currentLoc;
            sourceItem:Rectangle{
              anchors.centerIn: parent;
              width: units.gu(5);
              height: width;
              border.color:"white";
              border.width: 1;
              radius: width/2;
              color:"red";
              rotation: root.currentDir;

              /*UbuntuComponents.Icon {
                  anchors.centerIn: parent;
                  width: 0.9*parent.width;
                  height: 0.9*parent.height;
                  color: if (src.position.directionValid) {"#FFFFFF"} else {"#FF0000"}
                  name: "keyboard-caps-enabled";
              }*/

            }
          }

          }


          Rectangle{
          id : loadingDialog
          anchors.fill: parent
          color: Suru.backgroundColor
          opacity: 0.8;
          visible : true

            BusyIndicator {
                anchors.centerIn: parent
                running: loadingDialog.visible
            }
          }

          Row {
            width: parent.width
            anchors.bottom: parent.bottom;
            anchors.horizontalCenter: parent.horizontalCenter;
          Button{
            id : zoomOut
            width: parent.width/3;

            onClicked: map.zoomLevel = map.zoomLevel - 1;
            background: Rectangle {
                color: Suru.backgroundColor;
            }
            contentItem: Text {
                text: '-';
                font.pointSize: units.gu(2)
                color: Suru.foregroundColor;
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            }
          Button{
            id : centerAtPosition
            width: parent.width/3;
            onClicked: {
                map.center = point.coordinate
                map.zoomLevel = 16}
            background: Rectangle {
                color: Suru.backgroundColor;
            }
            contentItem: Text {
                text: i18n.tr("Center");
                font.pointSize: units.gu(2)
                color: Suru.foregroundColor;
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
          }
          Button{
            id : zoomIn
            width: parent.width/3;
            onClicked: map.zoomLevel = map.zoomLevel + 1;
            background: Rectangle {
                color: Suru.backgroundColor;
            }
            contentItem: Text {
                text: '+';
                font.pointSize: units.gu(2)
                color: Suru.foregroundColor;
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
          }
          }


    PositionSource {
    id: src
    updateInterval: 1000
    active: true

    onPositionChanged: {
        point.coordinate = src.position.coordinate;
        if (src.position.directionValid) {
            point.rotation = src.position.direction;
        }
    }
    }
    }


    Page {
      id: secondPage
      anchors.fill: parent

      header: PageHeader {

          title: i18n.tr('List')

          trailingActionBar.actions: [
              Action {
                  iconName: 'reload'
                  text: i18n.tr('Reload from server');
                  onTriggered: python.loadFromServer();
              },
              Action {
                  iconName: 'camera-grid'
                  text: i18n.tr('Go to map')
                  onTriggered: stackview.currentIndex = 0;
              },
              Action {
                  iconName: 'stock_website'
                  text: i18n.tr('Select network')
                  onTriggered: stackview.currentIndex = 2;
              },
              Action {
                  iconName: 'info'
                  text: i18n.tr('Info')
                  onTriggered: stackview.currentIndex = 3;
              }
          ]
      }

      Rectangle {
              anchors.fill: parent
              color: Suru.backgroundColor

          ColumnLayout {
              spacing: 0
              anchors.fill: parent
              Rectangle {
                  height: nameFilter.height
                  width: parent.width
                  color: Suru.backgroundColor
                  border.color: Suru.foregroundColor
                  border.width: 2
                  anchors {
                        left: parent.left
                        top: parent.top
                        right: parent.right
                    }

                    TextField {
                        id: nameFilter

                        anchors {
                        left: parent.left
                        right: parent.right
                        }

                        color: Suru.foregroundColor
                        font.pointSize: units.gu(2.5)
                        inputMethodHints: Qt.ImhNoPredictiveText
                        placeholderText: qsTr(i18n.tr("Search"))
                        width: parent.width
                        background: Rectangle {
                            color: Suru.backgroundColor
                        }
                    }
            }

            SortFilterModel {
                id: veloSortFilterModel
                model: veloModel
                sortCaseSensitivity: Qt.CaseInsensitive;
                filter.property: 'name';
                filter.pattern: RegExp("" + nameFilter.text + "\\s?",'i');
            }

              ListView {
                  id: listView
                  flickableDirection: Flickable.VerticalFlick
                  boundsBehavior: Flickable.StopAtBounds
                  clip: true
                  model: veloSortFilterModel
                  highlight: highlight

                  delegate: ListItem {
                        id:veloDelegate
                        color: Suru.backgroundColor
                        height: layout.height + (divider.visible ? divider.height : 0)
                        onClicked: {
                            listView.currentIndex = index
                            stackview.currentIndex = 0
                            map.center =  QtPositioning.coordinate(latitude, longitude)
                            map.zoomLevel =  18
                            /*PropertyAnimation { target: veloModel.get(index).bg ; property: "bg"; to: "#FF0000"; duration: 1000 }*/
                            veloSortFilterModel.get(index).bg = "#FF0000";
                        }
                        /*onPressAndHold: {
                            if (root.favoriteStations.indexOf(index) > -1 ) {
                                root.favoriteStations.splice(index-1,1);
                            }
                            else {
                                root.favoriteStations.push(index)
                            }
                            console.log(root.favoriteStations)
                        }*/
                        ListItemLayout {
                            id: layout
                            title.color: Suru.foregroundColor;
                            subtitle.color: Suru.foregroundColor;
                            summary.color: Suru.foregroundColor;
                            title.text: name
                            subtitle.text: i18n.tr("Bikes")+": "+free_bikes+", "+ i18n.tr("Stands")+": "+empty_slots
                            summary.text: i18n.tr("Time since update: " + hours_since_update + i18n.tr("h ") + minutes_since_update + i18n.tr("m "))
                        }
                    }

                  Layout.fillWidth: true
                  Layout.fillHeight: true
                  ScrollBar.vertical: ScrollBar {}
              }
          }
      }
    }

    Page {
        anchors.fill: parent

        header: PageHeader {
            id: header
            title: i18n.tr("Select your network")

            trailingActionBar.actions: [

                Action {
                    iconName: 'tick'
                    text: i18n.tr('Check')
                    onTriggered: {
                      stackview.currentIndex = 0;
                      python.loadFromServer()
                    }
                }
            ]
            }



     Rectangle {
             anchors.fill: parent
             color: Suru.backgroundColor

         ListModel {
             id: networkModel
                 ListElement {
                     nw_id: "The ID"
                     city: "The city"
                     country: "The country"
                     latitude: 0.0
                     longitude: 0.0
                     filterproperty: ""
                     name: "The Name"
                 }
             }

             ColumnLayout {
                 spacing: 0
                 anchors.fill: parent
                 Rectangle {
                     height: networkFilter.height
                     width: parent.width
                     color: Suru.backgroundColor
                     border.color: Suru.foregroundColor
                     border.width: 2
                     anchors {
                           left: parent.left
                           top: parent.top
                           right: parent.right
                       }

                       TextField {
                           id: networkFilter
                           color: Suru.foregroundColor
                           font.pointSize: units.gu(2.5)
                           placeholderText: qsTr(i18n.tr("Search"))
                           width: parent.width
                           background: Rectangle {
                               color: Suru.backgroundColor
                           }
                       }
               }

             SortFilterModel {
                 id: networksSortFilterModel
                 model: networkModel
                 sortCaseSensitivity: Qt.CaseInsensitive;
                 filter.property: "filterproperty";
                 filter.pattern: RegExp("" + networkFilter.text + "\\s?",'i');
             }

         ListView {
             id: networksListView
             flickableDirection: Flickable.VerticalFlick
             boundsBehavior: Flickable.StopAtBounds
             clip: true
             model: networksSortFilterModel

             delegate: ListItem {
                   id: networksDelegate
                   color: Suru.backgroundColor
                   height: layout.height + (divider.visible ? divider.height : 0)
                       onClicked: {
                            root.network_ID = networksSortFilterModel.get(index)["nw_id"]
                            root.networkCenter = {'latitude': latitude, 'longitude': longitude}
                            stackview.currentIndex = 0;
                            map.center = QtPositioning.coordinate(networkCenter["latitude"], networkCenter["longitude"]);
                            python.loadFromServer()
                            }
                   ListItemLayout {
                       id: layout
                       title.color: Suru.foregroundColor;
                       subtitle.color: Suru.foregroundColor;
                       summary.color: Suru.foregroundColor;
                       title.text: name;
                       subtitle.text: city;
                       summary.text: country;

                   }
               }

             Layout.fillWidth: true
             Layout.fillHeight: true
             ScrollBar.vertical: ScrollBar {}
         }

     }

     }
     }


     Page {
         anchors.fill: parent

         header: PageHeader {
              title: i18n.tr("Info")
             id: infoPageHeader
             trailingActionBar.actions: [
                 Action {
                     iconName: 'back'
                     text: i18n.tr('Return to map')
                     onTriggered: stackview.currentIndex = 0;
                 }
             ]
             }

         Rectangle{
             anchors.fill: parent
             color: Suru.backgroundColor

         Column{
            anchors.centerIn: parent;
            width: parent.width
            anchors.top: infoPageHeader.bottom
            anchors.bottom: parent.bottom
            spacing: units.gu(4)

            Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 0.8* parent.width
                    font.weight: Font.DemiBold
                    text: "OpenVelo"
                    font.pointSize: units.gu(2.5)
                    horizontalAlignment:Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: Suru.foregroundColor
            }

             ProportionalShape {
                id: logo
                width: units.gu(17)
                source: Image {
                   source: "../assets/logo.svg"
                }
                anchors.horizontalCenter: parent.horizontalCenter
             }

         Label {
            text: i18n.tr("Version") + " " + Qt.application.version
            anchors.horizontalCenter: parent.horizontalCenter
            color: Suru.foregroundColor
         }


         Label {
                 anchors.horizontalCenter: parent.horizontalCenter
                 width: 0.8* parent.width
                 text: i18n.tr("Source code: <a href='https://github.com/hendrikscheewel/OpenVelo'>github.com/hendrikscheewel/OpenVelo</a>. ")
                 wrapMode: Text.WordWrap
                 horizontalAlignment:Text.AlignHCenter
                 verticalAlignment: Text.AlignVCenter
                 color: Suru.foregroundColor
                 onLinkActivated: Qt.openUrlExternally(link)
         }

      Label {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 0.8* parent.width
                text: i18n.tr("API: Open Velo uses open bike sharing data provided by <a href='https://citybik.es/'>citybik.es</a>. Learn more about the project <a href='https://citybik.es/#about'>here</a>. ")
                wrapMode: Text.WordWrap
                horizontalAlignment:Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Suru.foregroundColor
                onLinkActivated: Qt.openUrlExternally(link)
      }

      Label {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 0.8* parent.width
                text: i18n.tr("Thanks to all translators! ")
                wrapMode: Text.WordWrap
                horizontalAlignment:Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Suru.foregroundColor
      }

      }
    }

      }


    Python {
        id: python

        Component.onCompleted: {

            addImportPath(Qt.resolvedUrl('./'));

            importModule('main', function() {

                python.call('main.load_networks', [], function(returnValue) {

                    networkModel.clear()
                      for (var i = 0; i < returnValue.length; i = i+1)  {

                          networkModel.append({"nw_id": returnValue[i]['id'],
                                            "city":returnValue[i]['location']['city'],
                                            "latitude": returnValue[i]['location']['latitude'],
                                            "longitude": returnValue[i]['location']['longitude'],
                                            "country": returnValue[i]['location']['country'],
                                            "filterproperty":  returnValue[i]['location']['city'] + returnValue[i]['name'],
                                            "name": returnValue[i]['name']})
                }

                })


            });


            python.loadFromServer()


            }
        onError: {
            console.log('python error: ' + traceback);
            }

        function loadFromServer(){
                loadingDialog.visible =  true
                map.zoomLevel = 13
                veloModel.clear()

                python.call('main.load_stations', [network_ID], function(returnValue) {

                  for (var i = 0; i < returnValue.length; i = i+1)  {

                      veloModel.append({"empty_slots": returnValue[i]['empty_slots'],
                                        "free_bikes":returnValue[i]['free_bikes'],
                                        "station_ID": returnValue[i]['id'],
                                        "latitude": returnValue[i]['latitude'],
                                        "longitude": returnValue[i]['longitude'],
                                        "name": returnValue[i]['name'],
                                        "hours_since_update": returnValue[i]['time_since_update']['hours'],
                                        "minutes_since_update": returnValue[i]['time_since_update']['minutes'],
                                        "bg": "gray"})
                }
                loadingDialog.visible =  false




                })

            }




        }

    }

    Settings {
      id: settings
      property var network_ID: networkModel.get(0)['nw_id'];
      property var networkCenter: {'latitude': networkModel.get(0)["latitude"], 'longitude': networkModel.get(0)["longitude"]}
      property var favoriteStations: [];
    }


    Component.onDestruction: {
            settings.network_ID = root.network_ID
            settings.favoriteStations = root.favoriteStations
            settings.networkCenter = root.networkCenter

        }
}
