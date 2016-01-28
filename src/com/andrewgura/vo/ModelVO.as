package com.andrewgura.vo {

import away3d.entities.Mesh;

import com.andrewgura.nfs12NativeFileFormats.models.ModelDescriptionVO;
import com.andrewgura.nfs12NativeFileFormats.models.SubModelDescriptionVO;
import com.andrewgura.utils.ModelLoader;

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

    public function serialize():Object {
        var subModels:Array = [];
        for each (var subModel:SubModelDescriptionVO in modelDescription.subModels) {
            subModels.push({matId: subModel.textureID, vertexData: subModel.vertexData, indexData: subModel.indexData, uvData: subModel.uvData});
        }
        return {name: name, subModels: subModels};
    }

    public function deserialize(data:Object):void {
        for (var i:Number = 0; i < (data.subModels as Array).length; i++) {
            var subModelDesc:SubModelDescriptionVO = new SubModelDescriptionVO(data.subModels[i].matId);
            subModelDesc.textureID = data.subModels[i].matId;
            subModelDesc.vertexData = data.subModels[i].vertexData;
            subModelDesc.indexData = data.subModels[i].indexData;
            subModelDesc.uvData = data.subModels[i].uvData;
            modelDescription.subModels.addItem(subModelDesc);
        }
        var modelLoader:ModelLoader = new ModelLoader(this);
        modelLoader.load();
    }

}
}