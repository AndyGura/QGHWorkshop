package com.andrewgura.utils {
import away3d.core.base.Geometry;
import away3d.core.base.SubGeometry;
import away3d.entities.Mesh;
import away3d.materials.ColorMaterial;
import away3d.materials.MaterialBase;
import away3d.materials.TextureMaterial;
import away3d.textures.ATFTexture;

import com.andrewgura.nfs12NativeFileFormats.models.SubModelDescriptionVO;
import com.andrewgura.vo.ModelVO;

import mx.collections.ArrayCollection;

public class ModelLoader {

    private var model:ModelVO;

    public function ModelLoader(model:ModelVO) {
        this.model = model;
        super();
    }

    public function load(textures:ArrayCollection = null):void {
        trace("### MODEL LOAD ROUTINE!!!");
        var fullMesh:Mesh;
        for each (var subModelDescription:SubModelDescriptionVO in model.modelDescription.subModels) {
            if (subModelDescription.vertexData.length == 0) {
                continue;
            }
            var subGeom:SubGeometry = new SubGeometry();
            subGeom.updateVertexData(subModelDescription.vertexData);
            subGeom.updateIndexData(subModelDescription.indexData);
            subGeom.updateUVData(subModelDescription.uvData);
            var geom:Geometry = new Geometry;
            geom.addSubGeometry(subGeom);
            var texture:com.andrewgura.vo.TextureVO;
            if (textures) {
                for each (var t:com.andrewgura.vo.TextureVO in textures) {
                    if (t.name == subModelDescription.textureID) {
                        texture = t;
                        break;
                    }
                }
            }
            if (texture) {
                texture.atfData.position = 0;
            }
            var material:MaterialBase = texture ? new TextureMaterial(new ATFTexture(texture.atfData)) : new ColorMaterial(Math.random() * 0xffffff);
            if (!fullMesh) {
                fullMesh = new Mesh(geom, material);
            } else {
                var mesh:Mesh = new Mesh(geom, material);
                fullMesh.addChild(mesh);
            }
        }
        model.mesh = fullMesh;
    }

}
}
