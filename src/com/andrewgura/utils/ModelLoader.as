package com.andrewgura.utils {
import away3d.core.base.Geometry;
import away3d.core.base.SubGeometry;
import away3d.entities.Mesh;
import away3d.materials.ColorMaterial;
import away3d.materials.MaterialBase;

import com.andrewgura.nfs12NativeFileFormats.models.ModelDescriptionVO;
import com.andrewgura.nfs12NativeFileFormats.models.SubModelDescriptionVO;
import com.andrewgura.vo.ModelVO;

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
            var material:MaterialBase = new ColorMaterial(Math.random() * 0xffffff);
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
