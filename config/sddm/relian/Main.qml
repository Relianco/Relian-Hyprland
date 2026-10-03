import QtQuick 2.0
import SddmComponents 2.0
import "art.js" as Art

// Relian login: logo, padlock, password box. Pick the user's last session if it is Hyprland, else prefer uwsm/Hyprland.
// "@BG@" is replaced with the theme background colour by tools/build-sddm-theme.py.
Rectangle {
  id: root
  width: 640
  height: 480
  color: "@BG@"

  property string currentUser: userModel.lastUser
  property bool loginFailed: false
  property int sessionIndex: {
    var hypr = -1
    for (var i = 0; i < sessionModel.rowCount(); i++) {
      var name = (sessionModel.data(sessionModel.index(i, 0), Qt.DisplayRole) || "").toString().toLowerCase()
      if (name.indexOf("uwsm") !== -1 && name.indexOf("hyprland") !== -1) return i
      if (hypr < 0 && name.indexOf("hyprland") !== -1) hypr = i
    }
    return hypr >= 0 ? hypr : sessionModel.lastIndex
  }

  // Animated backdrop: the screensaver's ASCII art, dim, in the accent colour. A brighter band sweeps across it and the
  // art changes every ~25s, so a locked screen still looks alive but clearly is not the screensaver.
  Item {
    id: backdrop
    anchors.fill: parent
    property int idx: Math.floor(Math.random() * Art.ART.length)
    property real fit: Math.min(width * 0.92 / dim.implicitWidth, height * 0.92 / dim.implicitHeight)

    Item {
      id: stage
      anchors.centerIn: parent
      width: dim.implicitWidth; height: dim.implicitHeight
      scale: backdrop.fit
      opacity: 0.0

      Text { id: dim; text: Art.ART[backdrop.idx]; color: "@ACCENT@"; opacity: 0.12
             font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14; textFormat: Text.PlainText }

      Item {                      // the sweeping highlight: a clipped copy of the art, brighter
        id: band
        width: dim.implicitWidth * 0.12; height: parent.height; clip: true
        NumberAnimation on x { from: -band.width; to: dim.implicitWidth; duration: 7000; loops: Animation.Infinite }
        Text { x: -band.x; text: dim.text; color: "@ACCENT@"; opacity: 0.45
               font.family: dim.font.family; font.pixelSize: 14; textFormat: Text.PlainText }
      }

      SequentialAnimation on opacity {
        id: cycle; loops: Animation.Infinite
        NumberAnimation { to: 1.0; duration: 2500 }
        PauseAnimation { duration: 20000 }
        NumberAnimation { to: 0.0; duration: 2500 }
        ScriptAction { script: backdrop.idx = (backdrop.idx + 1) % Art.ART.length }
      }
    }
  }

  Connections {
    target: sddm
    function onLoginFailed() {
      root.loginFailed = true
      password.text = ""
      password.focus = true
    }
    function onLoginSucceeded() { root.loginFailed = false }
  }

  Column {
    anchors.centerIn: parent
    spacing: 40

    Image {
      id: logo
      source: "logo.png"
      width: Math.min(sourceSize.width, root.width * 0.8)
      height: sourceSize.width > 0 ? Math.round(width * sourceSize.height / sourceSize.width) : 0
      fillMode: Image.PreserveAspectFit
      anchors.horizontalCenter: parent.horizontalCenter
    }

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 15

      Image {
        source: root.loginFailed ? "lock-failed.png" : "lock.png"
        width: 34
        height: 38
        fillMode: Image.PreserveAspectFit
        anchors.verticalCenter: parent.verticalCenter
      }

      Item {
        width: entry.width
        height: entry.height

        Image {
          id: entry
          source: root.loginFailed ? "entry-failed.png" : "entry.png"
          anchors.centerIn: parent
        }

        Row {
          anchors.left: parent.left
          anchors.leftMargin: 20
          anchors.verticalCenter: parent.verticalCenter
          spacing: 5

          Repeater {
            model: Math.min(password.text.length, 21)
            Image { source: "bullet.png"; width: 7; height: 7 }
          }
        }

        TextInput {
          id: password
          anchors.fill: parent
          anchors.leftMargin: 20
          anchors.rightMargin: 20
          verticalAlignment: TextInput.AlignVCenter
          echoMode: TextInput.Password
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: 24
          font.letterSpacing: 5
          passwordCharacter: "•"
          color: "transparent"
          selectionColor: "transparent"
          selectedTextColor: "transparent"
          cursorDelegate: Item {}
          focus: true

          onTextChanged: root.loginFailed = false

          Keys.onPressed: {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              sddm.login(root.currentUser, password.text, root.sessionIndex)
              event.accepted = true
            }
          }
        }
      }
    }
  }

  Component.onCompleted: password.forceActiveFocus()
}
