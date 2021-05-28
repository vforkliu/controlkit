

/*
 * SPDX-FileCopyrightText: (C) 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */
import QtQuick 2.15
import QtQuick.Controls 2.10 as QQC2

import org.kde.kirigami 2.15 as Kirigami

Kirigami.Page {
    id: cropView
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0
    globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None

    //要裁剪的图片的实际宽高
    property int cropImageWidth:    cropView.width * 4 / 5
    property int cropImageHeight:    cropView.height * 4 / 5
    //要裁剪的图片路径
    property string imageUrl: ""
    //旋转次数
    property int rotateCount: 0
    width: parent.width
    height: parent.height

    signal cropImageFinished(string path)
    signal closePage();

    Rectangle {
        anchors.fill: parent
        color: "black"
    }

    Kirigami.JImageDocument {
        id: imageDoc
        property bool isCropping:false
        providerImage:true
        path: cropView.imageUrl
        onVisualImageChanged: {
            //裁剪完成后,会触发该信号,但是不需要刷新界面,不显示裁剪后的图片
            if(isCropping === true){
                console.log("jimage document visual image changed  iscropping .so return");
                return;
            }
            console.log("jimage document visual image changed ")

            imgViewer.width = cropImageWidth;
            imgViewer.height = cropImageHeight;

            imgViewer.source = "";
            imgViewer.source = "image://cropImageProvider/cropImage";
        }

        onCropImageFinished:{
            //图片裁剪完成
            console.log("jimage document crop image finished " + path)
            isCropping = false;
            cropView.cropImageFinished(path);
        }
    }

    JImageViewer{
        id:imgViewer
        anchors.centerIn: parent
        width: cropImageWidth
        height: cropImageHeight
        fullScreen: true
        //source: "image://cropImageProvider/cropImage"
        onInitFinished: {
            //初始化裁剪框位置
            resizeRectangle.width = imgViewer.editImg.width
            resizeRectangle.height = imgViewer.editImg.height
            resizeRectangle.x = (cropView.width - imgViewer.editImg.width) / 2;
            resizeRectangle.y = (cropView.height - imgViewer.editImg.height) / 2
            resizeRectangle.moveAreaRect = Qt.rect( resizeRectangle.x, resizeRectangle.y, resizeRectangle.width, resizeRectangle.height);

            console.log("resize rectnagle x is " + resizeRectangle.x + "  y is " + resizeRectangle.y
                        + " width is " + resizeRectangle.width + "  height is " + resizeRectangle.height)

            vabView.width = resizeRectangle.width
            vabView.height = resizeRectangle.height
            vabView.x = resizeRectangle.x;
            vabView.y = resizeRectangle.y;
        }
    }

    Kirigami.JBlurBackground{
        id:vabView
        visible: resizeRectangle.isMoving === false && resizeRectangle.resizePressed === false && resizeRectangle.isRectChanged === true
        showBgCover:false
        sourceItem: imgViewer
        backgroundColor:"#EDFFFFFF"
        blurRadius: 130
        radius: 0
    }

    NumberAnimation {
        id:vabViewAnima
        target: vabView
        property: "opacity"
        from: 0
        to: 1
        duration: 250
        easing.type: Easing.InOutQuad
    }

    Kirigami.JResizeRectangle {
        id: resizeRectangle

        property bool isRectChanged:false
        property bool resizePressed: rzTopLeft.isPressed || rzBottomLeft.isPressed || rzBottomRight.isPressed || rzTopRight.isPressed

        onWidthChanged: {
            isRectChanged = (width !== imgViewer.editImg.width)
            if(vabView.opacity !== 0){
                vabViewAnima.from = 1.0
                vabViewAnima.to = 0
                vabViewAnima.running = true
            }
        }
        onHeightChanged: {
            isRectChanged = (height !== imgViewer.editImg.height)

            if(vabView.opacity !== 0.0){
                vabViewAnima.from = 1.0
                vabViewAnima.to = 0.0
                vabViewAnima.running = true
            }
        }
        JBasicResizeHandle {
            id: rzTopLeft
            rectangle: resizeRectangle
            resizeCorner: Kirigami.JResizeHandle.TopLeft
            moveAreaRect:  Qt.rect(imgViewer.x,imgViewer.y,imgViewer.width,imgViewer.height)

            onOnReleased: {
                if(vabView.opacity !== 1.0){
                    vabViewAnima.from = 0
                    vabViewAnima.to = 1.0
                    vabViewAnima.running = true
                }
            }
        }

        JBasicResizeHandle {
            id: rzBottomLeft
            rectangle: resizeRectangle
            resizeCorner: Kirigami.JResizeHandle.BottomLeft
            moveAreaRect:  Qt.rect(imgViewer.x,imgViewer.y,imgViewer.width,imgViewer.height)

            onOnReleased: {
                if(vabView.opacity !== 1.0){
                    vabViewAnima.from = 0
                    vabViewAnima.to = 1.0
                    vabViewAnima.running = true
                }
            }
        }

        JBasicResizeHandle {
            id: rzBottomRight
            rectangle: resizeRectangle
            resizeCorner: Kirigami.JResizeHandle.BottomRight
            moveAreaRect:  Qt.rect(imgViewer.x,imgViewer.y,imgViewer.width,imgViewer.height)

            onOnReleased: {
                if(vabView.opacity !== 1.0){
                    vabViewAnima.from = 0
                    vabViewAnima.to = 1.0
                    vabViewAnima.running = true
                }
            }
        }

        JBasicResizeHandle {
            id:rzTopRight
            rectangle: resizeRectangle
            resizeCorner: Kirigami.JResizeHandle.TopRight
            moveAreaRect:  Qt.rect(imgViewer.x,imgViewer.y,imgViewer.width,imgViewer.height)

            onOnReleased: {
                if(vabView.opacity !== 1.0){
                    vabViewAnima.from = 0
                    vabViewAnima.to = 1.0
                    vabViewAnima.running = true
                }
            }
        }
        ShaderEffectSource {
            id: ett
            anchors.fill: parent
            visible: vabView.visible
            live:visible
            sourceItem: imgViewer
            onVisibleChanged: {
                if(visible){
                    var pos = ett.mapToItem(imgViewer, 0, 0);
                    ett.sourceRect = Qt.rect(pos.x, pos.y, width, height)
                }
            }
        }

        Row {
            anchors.fill: parent
            spacing: width / 3 - 1
            Repeater {
                model: 4
                delegate: Rectangle {
                    width: 1
                    height: parent.height
                }
            }
        }

        Column {
            anchors.fill: parent
            spacing: height / 3 - 1
            Repeater {
                model: 4
                delegate: Rectangle {
                    width: parent.width
                    height: 1
                }
            }
        }

    }

    Rectangle {
        id: rightToolView

        //图片是否被修改,包括旋转,裁剪
        property bool isModified: doneImage.opacity === 1.0

        width: parent.width / 10
        height: parent.height
        color: "transparent"
        anchors {
            top: parent.top
            topMargin: reduction.height * 2
            bottom: parent.bottom
            right: parent.right
        }

        Text {
            id: reduction

            color: rightToolView.isModified ? "#FFFFFF" : "#4DFFFFFF"
            text: i18nd("kirigami-controlkit", "Reduction")
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 10

            MouseArea {
                anchors.fill: reduction
                onClicked: {
                    if (rightToolView.isModified) {
                        abandionDialog.open()
                    }
                }
            }
        }

        Image {
            id: rotateImage

            anchors {
                bottom: cancelImage.top
                bottomMargin: 22
                horizontalCenter: parent.horizontalCenter
            }
            source: "../image/imagePreviewIcon/crop_rotate.png"
            width: 22
            height: width

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    cropView.rotateCount++
                    imageDoc.rotate(90)
                }
            }
        }

        Image {
            id: cancelImage

            source: "../image/imagePreviewIcon/crop_delete.png"
            width: 22
            height: width
            anchors {
                bottom: doneImage.top
                bottomMargin: 22
                horizontalCenter: parent.horizontalCenter
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    cropView.closePage();
                }
            }
        }

        Image {
            id: doneImage

            source: "../image/imagePreviewIcon/done.png"
            width: 22
            height: width
            opacity: (resizeRectangle.isRectChanged === true || (cropView.rotateCount % 4 !== 0)) ? 1.0 : 0.5
            anchors {
                bottom: parent.bottom
                bottomMargin: 22
                horizontalCenter: parent.horizontalCenter
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (rightToolView.isModified) {
                        crop()
                    }
                }
            }
        }
    }

    Kirigami.JDialog{
        id:abandionDialog
        title: i18nd("kirigami-controlkit", "Abandoning modification")
        text: i18nd("kirigami-controlkit", "Are you sure to discard the current modification")
        rightButtonText: i18nd("kirigami-controlkit", "Action")
        leftButtonText: i18nd("kirigami-controlkit", "Cancel")
        visible:false

        onLeftButtonClicked:{
            abandionDialog.close()
        }

        onRightButtonClicked:{
            abandionDialog.close()
            cropView.rotateCount = 0;
            imageDoc.clearUndoImage()
        }
    }

    function crop() {

        const ratioX = imgViewer.editImg.width * 1.0 / imgViewer.editImg.item.sourceSize.width
        const ratioY = imgViewer.editImg.height * 1.0 / imgViewer.editImg.item.sourceSize.height;
        //裁剪图片的x,y坐标映射到cropview上的位置,
//        var cRect = cropEditImage.mapToItem(cropView, imgViewer.editImg.x, imgViewer.editImg.y)
//        imageDoc.crop((resizeRectangle.x - cRect.x),
//                      (resizeRectangle.y - cRect.y),
//                      resizeRectangle.width,
//                      resizeRectangle.height);


        console.log("crop image width is " + imgViewer.editImg.width + "  height is " + imgViewer.editImg.height
                    + " source size is " + imgViewer.editImg.item.sourceSize
                    + "  resize rect x is " + resizeRectangle.x + " y is " + resizeRectangle.y
                    + " width is " + resizeRectangle.width + "  height " + resizeRectangle.height)

        var cRect = resizeRectangle.mapToItem(imgViewer.editImg, 0, 0, resizeRectangle.width, resizeRectangle.height);
        console.log("after map ratiox is " + ratioX + "  ratioy " + ratioY + " crect x is " + cRect.x + "  y is " + cRect.y
                    + " crect  width " + cRect.width + "  height " + cRect.height)

        imageDoc.isCropping = true;
        imageDoc.crop(cRect.x / ratioX, cRect.y / ratioY, cRect.width / ratioX, cRect.height / ratioY);
        imageDoc.saveAs()
    }
}
