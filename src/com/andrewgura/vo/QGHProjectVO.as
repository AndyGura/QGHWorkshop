package com.andrewgura.vo {

import flash.utils.ByteArray;

import mx.collections.ArrayCollection;

import spark.collections.Sort;
import spark.collections.SortField;

[Bindable]
public class QGHProjectVO extends ProjectVO {

    public var outputQghPath:String = '';
    public var modelsCollection:ArrayCollection = new ArrayCollection();

    public function QGHProjectVO() {
        super();
        var sort:Sort = new Sort();
        sort.fields = [new SortField("name")];
        modelsCollection.sort = sort;
        modelsCollection.refresh();
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
    }


}

}