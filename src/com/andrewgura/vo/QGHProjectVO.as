package com.andrewgura.vo {

import com.andrewgura.controllers.QGHController;

import flash.utils.ByteArray;

import mx.collections.ArrayCollection;
import mx.events.CollectionEvent;

import spark.collections.Sort;
import spark.collections.SortField;

[Bindable]
public class QGHProjectVO extends ProjectVO {

    public static const ATTACHED_TEXTURES_CHANGE:String = "ATTACHED_TEXTURES_CHANGE";

    public var outputQghPath:String = '';
    public var contentCollection:ArrayCollection = new ArrayCollection();
    private var _attachedTCA:TCAProjectVO;
    public function get attachedTCA():TCAProjectVO {
        return _attachedTCA;
    }

    public function set attachedTCA(value:TCAProjectVO):void {
        if (_attachedTCA) {
            _attachedTCA.removeEventListener(TCAProjectVO.TEXTURES_COLLECTION_CHANGE, onTexturesChange);
        }
        _attachedTCA = value;
        if (_attachedTCA) {
            _attachedTCA.addEventListener(TCAProjectVO.TEXTURES_COLLECTION_CHANGE, onTexturesChange);
        }
    }

    public function QGHProjectVO() {
        super();
        var sort:Sort = new Sort();
        sort.fields = [new SortField("name")];
        contentCollection.sort = sort;
        contentCollection.refresh();
    }

    override public function serialize():ByteArray {
        var output:ByteArray = super.serialize();
        output.compress();
        return output;
    }

    override public function deserialize(name:String, fileName:String, data:ByteArray):void {
        super.deserialize(name, fileName, data);

    }

    override public function importFiles(files:Array):void {
        (new QGHController(this)).importFiles(files);
    }

    private function onTexturesChange(event:CollectionEvent):void {
        dispatchEvent(new CollectionEvent(ATTACHED_TEXTURES_CHANGE, false, false, event.kind, event.location, event.oldLocation, event.items));
    }

}

}
