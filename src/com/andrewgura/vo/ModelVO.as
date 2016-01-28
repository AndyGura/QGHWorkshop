package com.andrewgura.vo {

import away3d.entities.Mesh;

import com.andrewgura.nfs12NativeFileFormats.models.ModelDescriptionVO;

import flash.utils.ByteArray;

[Bindable]
public class ModelVO {

    public var name:String;
    public var mesh:Mesh;
    public var modelDescription:ModelDescriptionVO;

    public var processingProgress:Number = 0;

    public function ModelVO(name:String) {
        this.name = name;
    }

    public function serialize():ByteArray {
        var output:ByteArray = new ByteArray();
//        output.writeObject({name: name, atfData: atfData, atfWidth: atfWidth, atfHeight: atfHeight});
//        var rect:Rectangle = new Rectangle(0, 0, sourceBitmap.width, sourceBitmap.height);
//        var bytes:ByteArray = sourceBitmap.bitmapData.getPixels(rect);
//        output.writeObject({rect: rect, data: bytes});
        return output;
    }

    public function deserialize(data:ByteArray):void {
//        var o:* = data.readObject();
//        for (var field:String in o) {
//            this[field] = o[field];
//        }
//        o = data.readObject();
//        var rect:Rectangle = new Rectangle(0, 0, o.rect.width, o.rect.height);
//        var bitmapData:BitmapData = new BitmapData(rect.width, rect.height, true);
//        bitmapData.setPixels(rect, o.data);
//        sourceBitmap = new Bitmap(bitmapData);
    }

}
}