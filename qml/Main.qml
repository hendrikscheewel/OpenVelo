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
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3

import QtLocation 5.3
import QtPositioning 5.6
import Ubuntu.DownloadManager 1.2




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

    property var contractInfo : {'amiens': {'lat': 49.89343146619912, 'lng': 2.297113237744805},
                       'besancon': {'lat': 47.23979510000001, 'lng': 6.025420200000001},
                       'brisbane': {'lat': -27.47141017880795, 'lng': 153.0250157483445},
                       'bruxelles': {'lat': 50.84322682279418, 'lng': 4.360707950690179},
                       'cergy-pontoise': {'lat': 49.037306240004774, 'lng': 2.060685502658265},
                       'creteil': {'lat': 48.78368079387765, 'lng': 2.4604914536676192},
                       'dublin': {'lat': 53.345491890909074, 'lng': -6.264740490909093},
                       'lillestrom': {'lat': 59.959140999999995, 'lng': 11.050151833333333},
                       'ljubljana': {'lat': 46.05726988709677, 'lng': 14.509747612903224},
                       'lund': {'lat': 55.70781944981111, 'lng': 13.199646972419036},
                       'luxembourg': {'lat': 49.60923811044996, 'lng': 6.128290604781318},
                       'lyon': {'lat': 45.759899198171524, 'lng': 4.851031146390814},
                       'marseille': {'lat': 43.286037002902354, 'lng': 5.381312737290675},
                       'mulhouse': {'lat': 47.74718901912745, 'lng': 7.336393379959304},
                       'namur': {'lat': 50.46329410344827, 'lng': 4.862059644827587},
                       'nancy': {'lat': 48.689073674659326, 'lng': 6.179954739185165},
                       'nantes': {'lat': 47.21552205668433, 'lng': -1.554300720020954},
                       'rouen': {'lat': 49.43713614831786, 'lng': 1.0914493828679648},
                       'santander': {'lat': 43.46589772465013, 'lng': -3.807747886114248},
                       'seville': {'lat': 37.389017383029795, 'lng': -5.977712213028738},
                       'toulouse': {'lat': 43.60228733265252, 'lng': 1.4432994953266045},
                       'toyama': {'lat': 36.69759243478261, 'lng': 137.20841069565216},
                       'valence': {'lat': 39.47167040532542, 'lng': -0.3713211435362771},
                       'vilnius': {'lat': 54.688745485945944, 'lng': 25.282028273783784}};

    property var contracts : Object.keys(contractInfo);

    function capitalizeListItems(li) {
      var i;
      for (i = 0; i < li.length; i++) {
        li[i] = li[i].slice(0,1).toUpperCase() + li[i].slice(1);
      }
      return li
    }

    property var contractsCapital : capitalizeListItems(contracts)


    property var contractName : settings.contractName


        StackLayout {
            id: stackview
            anchors.fill : parent


            Page {
                anchors.fill: parent

                header: PageHeader {

                    title: i18n.tr('Map')

                    trailingActionBar.actions: [
                    Action {
                        iconName: 'settings'
                        text: i18n.tr('Settings')
                        onTriggered: stackview.currentIndex = 2;
                    },
                    Action {
                        iconName: 'reload'
                        text: i18n.tr('Reload from Server');
                        onTriggered: python.loadFromServer();
                    },
                    Action {
                        iconName: 'view-list-symbolic'
                        text: i18n.tr('Update Location')
                        onTriggered: stackview.currentIndex = 1;
                    }
                    ]
                }


    Map {
        id: map
        anchors.fill: parent
        plugin: mapPlugin
        zoomLevel: 13
        center: QtPositioning.coordinate(root.contractInfo[root.contractName.toLowerCase()]['lat'], root.contractInfo[root.contractName.toLowerCase()]['lng'])

        ListModel {
            id: veloModel

            }
          MapItemView {
              model: veloModel
              delegate: MapQuickItem {
                  coordinate: QtPositioning.coordinate(lat, lng)
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
                       color:"#666666";
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
                       color:"#666666";
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
                      text: number;
                      font.bold :true;
                    }
                    Text{
                      width: 0.8*innerCircle.width
                      maximumLineCount: 2
                      anchors.horizontalCenter: parent.horizontalCenter;
                      color: "white";
                      horizontalAlignment: Text.AlignHCenter;
                      text: name.split(' - ')[0]//.slice(0, 12) + '...';
                      wrapMode: Text.Wrap
                      font.pointSize: 20
                    }
                    Row {
                      id: busyBar
                      anchors.horizontalCenter: parent.horizontalCenter;
                      Text {
                          color: "#CCCCCC";
                          //font.pixelSize: 16;
                          text: available_bikes + ' ';
                          horizontalAlignment: Text.AlignRight;
                          font.pointSize: 15
                      }
                      Rectangle {
                        id: bikeBar
                        width: 0.5*innerCircle.width*available_bikes/(available_bikes+available_bike_stands);
                        height: 0.1*innerCircle.width;
                        color: "#444444";
                      }
                      Rectangle {
                        id: standsBar
                        width: 0.5*innerCircle.width*available_bike_stands/(available_bikes+available_bike_stands);
                        height: 0.1*innerCircle.width;
                        color: "#CCCCCC";
                      }
                      Text {
                          color: "#CCCCCC";
                          text: ' ' + available_bike_stands;
                          horizontalAlignment: Text.AlignLeft;
                          font.pointSize: 15
                      }
                    }
                    Row {
                      id: barLabels
                      width : busyBar.width
                      anchors.horizontalCenter: parent.horizontalCenter;
                      //spacing: 0.4*innerCircle.width
                      /*Image {
                        id: bikesIcon
                        source: "../assets/bikes.svg";
                        height: 16;
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignLeft
                        width: height;
                      Item {
                          width: barLabels.width-bikesIcon.width-standsIcon.width;
                          height: 10
                          Layout.fillWidth: true
                          Layout.alignment: Qt.AlignHCenter
                      }
                      }
                      Image {
                        id: standsIcon
                        source: "../assets/stands.svg";
                        height: 16;
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignRight
                        width: height;
                      }*/
                      Text {
                          id: bikesLabel
                          color: "#CCCCCC";
                          font.pointSize: 15;
                          text: "Bikes";
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
                          font.pointSize: 15;
                          text: "Stands";
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
            coordinate : QtPositioning.coordinate(root.contractInfo[root.contractName.toLowerCase()]['lat'], root.contractInfo[root.contractName.toLowerCase()]['lng']);
            sourceItem:Rectangle{
              anchors.centerIn: parent;
              width: units.gu(5);
              height: width;
              border.color:"white";
              border.width: 1;
              radius: width/2;
              color:"red";
            }
          }

          }


          Rectangle{
          id : loadingDialog
          anchors.fill: parent
          color: '#888888'
          opacity: 0.8;
          visible : true

            BusyIndicator {
                anchors.centerIn: parent
                running: loadingDialog.visible
            }
          }

          Row {
            width: parent.width
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
          Button{
            id : zoomOut
            width: parent.width/3
            text: '-'
            onClicked: map.zoomLevel = map.zoomLevel - 1
            }
          Button{
            id : centerAtPosition
            width: parent.width/3
            text: 'Center'
            onClicked: map.center = point.coordinate
          }
          Button{
            id : zoomIn
            width: parent.width/3
            text: '+'
            onClicked: map.zoomLevel = map.zoomLevel + 1
          }
          }


    PositionSource {
    id: src
    updateInterval: 1000
    active: true

    onPositionChanged: {
        point.coordinate = src.position.coordinate;
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
              iconName: 'settings'
              text: i18n.tr('Settings')
              onTriggered: stackview.currentIndex = 2;
              },
              Action {
                  iconName: 'camera-grid'
                  text: i18n.tr('Update Location')
                  onTriggered: stackview.currentIndex = 0;
              }
          ]
      }



          ColumnLayout {
              anchors.fill: parent

              ListView {
                  id: listView
                  flickableDirection: Flickable.VerticalFlick
                  boundsBehavior: Flickable.StopAtBounds
                  clip: true
                  model: veloModel

                  delegate: ListItem {
                        id:veloDelegate
                        height: layout.height + (divider.visible ? divider.height : 0)
                        ListItemLayout {
                            id: layout
                            title.text: "<b>"+number+"</b> "+name.split(" - ")[0]
                            title.color: "#888888";
                            subtitle.text: "Address: "+name.split(" - ")[1]
                            summary.text: "Bikes: "+available_bikes+", Stands: "+available_bike_stands
                        }
                    }

                  Layout.fillWidth: true
                  Layout.fillHeight: true

                  ScrollBar.vertical: ScrollBar {}
              }
          }

    }

    Page {
        anchors.fill: parent

        header: PageHeader {
            id: header
            title: i18n.tr("Settings")



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


         ButtonGroup {
             id: buttonGroup
         }

         ListView {
            id: contractSelection
             anchors.fill: parent
             width: parent.width
             model: root.contractsCapital
             delegate: RadioDelegate {
                id: radioList
                width: parent.width
                ButtonGroup.group: buttonGroup
                text: modelData
                checked: root.contractsCapital[index] == root.contractName//root.contractsCapital[index] == root.contractName//index == 6//
                onClicked: {
                        console.log(root.contractsCapital[index] + ' selected')
                        root.contractName = root.contractsCapital[index]
                       }
                }

         }

     }
     }


     Page {
         anchors.fill: parent

         header: PageHeader {
             trailingActionBar.actions: [
                 Action {
                     iconName: 'back'
                     text: i18n.tr('Rotate to map')
                     onTriggered: stackview.currentIndex = 0;
                 }
             ]
             }

      Text {
              anchors.fill: parent
              width: 0.8* parent.width
              text: "Please restart<br>this app to load<br>station information."
              font.pointSize: 24
              color: "gray"
              horizontalAlignment:Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter
      }
      }




    Python {
        id: python

        Component.onCompleted: {

            addImportPath(Qt.resolvedUrl('./'));

            importModule('main', function() {
            python.call('main.AllInfo', [root.contractName], function(returnValue) {

              for (var i = 0; i < returnValue.length; i = i+1)  {

                  veloModel.append({"number": returnValue[i]['number'],
                                    "name":returnValue[i]['address'],
                                    "available_bikes": returnValue[i]['available_bikes'],
                                    "available_bike_stands": returnValue[i]['available_bike_stands'],
                                    "lat": returnValue[i]['position']['lat'],
                                    "lng": returnValue[i]['position']['lng'],
                                    "status": returnValue[i]['status'],})
              }

              loadingDialog.visible =  false
            })

            });

            }
        onError: {
            console.log('python error: ' + traceback);
        }

        function loadFromServer(){
                loadingDialog.visible =  true
                map.zoomLevel = 13
                veloModel.clear()

                python.call('main.AllInfo', [root.contractName], function(returnValue) {

                  for (var i = 0; i < returnValue.length; i = i+1)  {

                      veloModel.append({"number": returnValue[i]['number'],
                                        "name":returnValue[i]['address'],
                                        "available_bikes": returnValue[i]['available_bikes'],
                                        "available_bike_stands": returnValue[i]['available_bike_stands'],
                                        "lat": returnValue[i]['position']['lat'],
                                        "lng": returnValue[i]['position']['lng'],
                                        "status": returnValue[i]['status'],})
                  }


                })
                loadingDialog.visible =  false
            }

    }

    }

    Settings {
      id: settings
      property var contractName: 'bruxelles';
    }


    Component.onDestruction: {
            settings.contractName = root.contractName
        }
}
