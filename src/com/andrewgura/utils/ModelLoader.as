package com.andrewgura.utils {
import away3d.core.base.Geometry;
import away3d.core.base.SubGeometry;
import away3d.entities.Mesh;
import away3d.materials.TextureMaterial;
import away3d.utils.Cast;

import com.andrewgura.nfs12NativeFileFormats.models.ModelDescriptionVO;
import com.andrewgura.nfs12NativeFileFormats.models.SubModelDescriptionVO;
import com.andrewgura.vo.ModelVO;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Matrix;

public class ModelLoader {

    private var model:ModelVO;

    public function ModelLoader(model:ModelVO) {
        this.model = model;
        super();
    }

    public function loadByDescription(description:ModelDescriptionVO):void {
        var fullMesh:Mesh;
        for each (var subModelDescription:SubModelDescriptionVO in description.subModels) {
            if (subModelDescription.vertexData.length == 0) {
                continue;
            }
            var subGeom:SubGeometry = new SubGeometry();
            subGeom.updateVertexData(subModelDescription.vertexData);
            subGeom.updateIndexData(subModelDescription.indexData);
            subGeom.updateUVData(subModelDescription.uvData);
            var geom:Geometry = new Geometry;
            geom.addSubGeometry(subGeom);
            if (!fullMesh) {
                fullMesh = new Mesh(geom, new TextureMaterial(Cast.bitmapTexture(getResized(new Bitmap(subModelDescription.texture)).bitmapData)));
            } else {
                var mesh:Mesh = new Mesh(geom, new TextureMaterial(Cast.bitmapTexture(getResized(new Bitmap(subModelDescription.texture)).bitmapData)));
                fullMesh.addChild(mesh);
            }
        }
        model.mesh = fullMesh;
    }

    private function getResized(bitmap:Bitmap):Bitmap {
        var scaleX:Number = calculateNewDimension(bitmap.width) / bitmap.width;
        var scaleY:Number = calculateNewDimension(bitmap.height) / bitmap.height;
        var matrix:Matrix = new Matrix();
        matrix.scale(scaleX, scaleY);
        var newBitmap:BitmapData = new BitmapData(calculateNewDimension(bitmap.width), calculateNewDimension(bitmap.height), true, 0);
        newBitmap.draw(bitmap, matrix);
        return new Bitmap(newBitmap);
    }

    private function calculateNewDimension(value:Number):Number {
        for (var i:Number = 1; i < 2048; i <<= 1) {
            if (i >= value) break;
        }
        return i;
    }

}
}
