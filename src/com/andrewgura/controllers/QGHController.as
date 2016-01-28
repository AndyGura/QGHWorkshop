package com.andrewgura.controllers {
import com.andrewgura.nfs12NativeFileFormats.NFSNativeResourceLoader;
import com.andrewgura.nfs12NativeFileFormats.NativeOripFile;
import com.andrewgura.nfs12NativeFileFormats.NativeShpiArchiveFile;
import com.andrewgura.nfs12NativeFileFormats.NativeWwwwArchiveFile;
import com.andrewgura.ui.popup.AppPopups;
import com.andrewgura.ui.popup.PopupFactory;
import com.andrewgura.utils.ModelLoader;
import com.andrewgura.vo.ModelVO;
import com.andrewgura.vo.QGHProjectVO;
import com.andrewgura.vo.TCAProjectVO;

import flash.events.Event;
import flash.filesystem.File;

import mx.collections.ArrayCollection;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;

public class QGHController {

    private var project:QGHProjectVO;

    public function QGHController(project:QGHProjectVO) {
        this.project = project;
        this.project.contentCollection.addEventListener(CollectionEvent.COLLECTION_CHANGE, onModelsChange);
    }

    public function onModelsChange(event:CollectionEvent):void {
        project.isChangesSaved = false;
        if (event.kind == CollectionEventKind.ADD || event.kind == CollectionEventKind.MOVE || event.kind == CollectionEventKind.UPDATE || event.kind == CollectionEventKind.REPLACE) {
            project.contentCollection.refresh();
        }
    }

    public function applyMaterials():void {
        if (!project || !project.contentCollection || !project.attachedTCA || !project.attachedTCA.imageCollection) {
            return;
        }
        for each (var item:* in project.contentCollection) {
            if (!(item is ModelVO)) {
                continue;
            }
            var modelLoader:ModelLoader = new ModelLoader(item as ModelVO);
            modelLoader.load(project.attachedTCA.imageCollection);
        }
    }

    public function importFiles(files:Array):void {
        for each (var file:File in files) {
            switch (file.extension.toLowerCase()) {
                case 'cfm':
                case 'fam':
                    try {
                        var nfsModels:ArrayCollection = NFSNativeResourceLoader.loadNativeFile(file);
                    } catch (e:Error) {
                        PopupFactory.instance.showPopup(AppPopups.ERROR_POPUP, file.name + ": " + e.message);
                        continue;
                    }
                    processWwwwArchive(nfsModels, file.name.substr(0, file.name.lastIndexOf('.')));
                    break;
            }
        }
    }

    private function processWwwwArchive(archive:ArrayCollection, name:String):void {
        var wwwwArchivesCount:Number = 0;
        var textureCollections:ArrayCollection = new ArrayCollection();
        for each (var thing:* in archive) {
            switch (true) {
                case thing is NativeOripFile:
                    var model:ModelVO = new ModelVO(thing.modelDescription.name);
                    model.modelDescription = thing.modelDescription;
                    addModel(model);
                    var loader:ModelLoader = new ModelLoader(model);
                    loader.load();
                    break;
                case thing is NativeShpiArchiveFile:
                    textureCollections.addItem(thing);
                    break;
                case thing is NativeWwwwArchiveFile:
                    processWwwwArchive(thing, name + '.' + wwwwArchivesCount++);
                    break;
            }
        }
        if (textureCollections.length > 0) {
            for each (var textureCollection:NativeShpiArchiveFile in textureCollections) {
                var tca:TCAProjectVO = new TCAProjectVO();
                tca.name = name + "_" + textureCollections.getItemIndex(textureCollection);
                tca.addEventListener(TCAProjectVO.LOADING_COMPLETE, saveAndOpenTCA);
//                tcaToSaveNames.addItem(tca.name);
                (new TCAController(tca)).importNfsData(textureCollection);
            }
        }

        function saveAndOpenTCA(event:Event):void {
            project.contentCollection.addItem(event.target);
        }

    }

    public function exportQGH():void {
//        var outputDirectory:File;
//        var outputPath:String = QGHProjectVO(project).outputQghPath;
//        if (outputPath.substr(0, 1) == "/") {
//            //we are using MVAWorkshop on linux under wine;
//            outputPath = 'Z:' + outputPath;
//        }
//        try {
//            var windowsPartitionPathIndex:Number = Math.max(outputPath.indexOf(':\\'), outputPath.indexOf(':/'));
//            if (windowsPartitionPathIndex == -1) {
//                // we are using relative output path;
//                var targetFile:File = (new File()).resolvePath(project.fileName);
//                outputDirectory = targetFile.parent.resolvePath(outputPath);
//            } else {
//                outputDirectory = new File(outputPath);
//            }
//        } catch (e:Error) {
//        }
//        if (!outputDirectory || !outputDirectory.exists || !outputDirectory.isDirectory) {
//            exportError('Wrong output project directory!');
//            return;
//        }
//        var fs:FileStream = new FileStream();
//        var tcaData:ByteArray = project.getExportedTCA();
//        fs.open(outputDirectory.resolvePath(project.name + '.tca'), FileMode.WRITE);
//        fs.writeBytes(tcaData);
//        fs.close();
//        PopupFactory.instance.showPopup(AppPopups.INFO_POPUP, 'Export success!');
    }

//    private function exportError(msg:String):void {
//        PopupFactory.instance.showPopup(AppPopups.ERROR_POPUP, msg, true, null, onOkClick);
//        function onOkClick(event:Event):void {
//            MainController.openProjectSettings();
//        }
//    }

    public function addModel(texture:ModelVO):void {
        var newName:String = getNewNameForDuplicate(texture.name);
        texture.name = newName;
        project.contentCollection.addItem(texture);
    }

    public function deleteItems(items:Array):void {
        if (project.contentCollection.length == 0) {
            return;
        }
        for each (var item:* in items) {
            project.contentCollection.removeItem(item);
        }
    }

    public function getNewNameForDuplicate(name:String, excludeIndex:Number = -1):String {
        var newName:String = name;
        var i:Number = 0;
        var foundTexture:ModelVO = getModelByName(newName);
        while (foundTexture != null && project.contentCollection.getItemIndex(foundTexture) != excludeIndex) {
            i++;
            newName = name + '_' + i;
            foundTexture = getModelByName(newName);
        }
        return newName;
    }

    public function getModelByName(name:String):ModelVO {
        for each (var texture:* in project.contentCollection) {
            if (texture.name == name) {
                return texture;
            }
        }
        return null;
    }

}
}
