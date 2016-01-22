package com.andrewgura.controllers {
import com.andrewgura.consts.SharedObjectConsts;
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

import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;

import mx.collections.ArrayCollection;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;

public class QGHController {

    private var project:QGHProjectVO;

    public function QGHController(project:QGHProjectVO) {
        this.project = project;
        this.project.modelsCollection.addEventListener(CollectionEvent.COLLECTION_CHANGE, onModelsChange);
    }

    public function onModelsChange(event:CollectionEvent):void {
        project.isChangesSaved = false;
        if (event.kind == CollectionEventKind.ADD || event.kind == CollectionEventKind.MOVE || event.kind == CollectionEventKind.UPDATE || event.kind == CollectionEventKind.REPLACE) {
            project.modelsCollection.refresh();
        }
    }

    private var tempDirectory:File;
    private var tcaToSaveNames:ArrayCollection = new ArrayCollection();

    public function importFiles(files:Array):void {
        if (!tempDirectory || !tempDirectory.exists) {
            tempDirectory = File.createTempDirectory();
        }
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
                    addModel(model);
                    var loader:ModelLoader = new ModelLoader(model);
                    loader.loadByDescription(thing.modelDescription);
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
                tcaToSaveNames.addItem(tca.name);
                (new TCAController(tca)).importNfsData(textureCollection);
            }
        }

        function saveAndOpenTCA(event:Event):void {
            var tca:TCAProjectVO = TCAProjectVO(event.target);
            var file:File = new File(tempDirectory.nativePath + '/' + tca.name + '.tcp');
            var fs:FileStream = new FileStream();
            fs.open(file, FileMode.WRITE);
            var exportedTCA:ByteArray = tca.serialize();
            fs.writeBytes(exportedTCA, 0, exportedTCA.length);
            fs.close();

            var config:Object = PersistanceController.getResource(SharedObjectConsts.WORKSHOP_SETTINGS);
            if (!config) {
                return;
            }
            var exeFile:File = new File(config.tcaWorkshopPath);
            if (!exeFile.exists) {
                return;
            }
            var nativeProcess:NativeProcess = new NativeProcess();
            var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
            nativeProcessStartupInfo.executable = exeFile;
            var args:Vector.<String> = new Vector.<String>();
            args.push(tempDirectory.nativePath + '/' + tca.name + '.tcp');
            nativeProcessStartupInfo.arguments = args;
            nativeProcess.start(nativeProcessStartupInfo);
            nativeProcess.closeInput();
            tcaToSaveNames.removeItem(tca.name);
            if (tcaToSaveNames.length == 0) {
                tempDirectory.deleteDirectoryAsync(true);
            }
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
        project.modelsCollection.addItem(texture);
    }

    public function deleteItems(items:Array):void {
        if (project.modelsCollection.length == 0) {
            return;
        }
        for each (var item:* in items) {
            project.modelsCollection.removeItem(item);
        }
    }

    public function getNewNameForDuplicate(name:String, excludeIndex:Number = -1):String {
        var newName:String = name;
        var i:Number = 0;
        var foundTexture:ModelVO = getModelByName(newName);
        while (foundTexture != null && project.modelsCollection.getItemIndex(foundTexture) != excludeIndex) {
            i++;
            newName = name + '_' + i;
            foundTexture = getModelByName(newName);
        }
        return newName;
    }

    public function getModelByName(name:String):ModelVO {
        for each (var texture:* in project.modelsCollection) {
            if (texture.name == name) {
                return texture;
            }
        }
        return null;
    }

}
}
