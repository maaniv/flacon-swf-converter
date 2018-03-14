package{
import by.blooddy.crypto.image.PNGEncoder;
import by.blooddy.crypto.serialization.JSONer;
import flash.desktop.InteractiveIcon;
import flash.desktop.NativeApplication;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.StageQuality;
import flash.events.Event;
import flash.events.InvokeEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;
import flash.utils.getQualifiedSuperclassName;

/*
typedef LabelDesc = {
  var name:String;
  var frame_begin:Int;
  var frame_end:Int;
}

typedef ViewData = {
  var matrix:Array<Number> = [a, b, c, d, tx, ty]
  var alpha:Number;
  var index:Int;
}

typedef FrameDesc = {
  var views_data:Array<ViewData>;
}

typedef InstanceData = {
  var instance:Object;
  var name:String;
}

typedef ClipDesc = {
  var fps:int;
  var frames_desc:Array<FramesDesc>;
  var views_desc:Array<ViewDesc>;
  
  temporal instances_data_:Array<InstanceData>
}

typedef ViewDesc = {
  var type:String;
  var name:String;
  var pivot_x:Float;
  var pivot_y:Float;
  optional var clip_desc:ClipDesc;
  optional var tex_name:String;
}

typedef ExportDesc = {
  var name:String;
  var view_desc:ViewDesc;
}
*/

/**
 * ...
 * @author maaniv
 */
public class Main extends Sprite {
  public function Main() {
    NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE,
      OnInvoke);   
  }
  private function OnInvoke(e:InvokeEvent):void {
    try {
      Run(e.arguments);
    } catch (err:*) {
      trace(err);
    }
  }
  
  private function Run(args:Array):void {
    for (var i:int = 0; i < args.length; ++i) {
      if (i + 1 == args.length) break;
      switch(args[i]) {
        case "--swf": swf_path_ = args[++i]; break;
        case "--atlas": descr_path_ = args[++i]; break;
        case "--out": out_dir_ = args[++i]; break;
        //case "--scale": {
          //var scale_tmp:Number = parseFloat(args[++i]);
          //if (scale_tmp > 0) scale_ = scale_tmp;
          //break;
        //}
      }
    }
    
    if (swf_path_ == null)
      throw new Error("--swf argument not found");
    if (descr_path_ == null)
      throw new Error("--atlas argument not found");
    if (out_dir_ == null)
      throw new Error("--out argument not found");
      
    try {
      descr_ = JSONer.parse(ReadFileAsString(descr_path_));
    } catch (err:*) {
      //throw new Error("parsing file: '" + atlas_ + "'");
    }
      
    var byte_array:ByteArray = ReadFileAsByteArray(swf_path_);
    
    var loader_ctx:LoaderContext = new LoaderContext();
    loader_ctx.allowCodeImport = true;
    //loader_ctx.securityDomain = SecurityDomain.currentDomain;
    //loader_ctx.applicationDomain = ApplicationDomain.currentDomain;     
    
    loader_ = new Loader();
    loader_.contentLoaderInfo.addEventListener(Event.COMPLETE, OnComplete);
    loader_.loadBytes(byte_array, loader_ctx);
  }
  
  private function OnComplete(e:Event):void {
    fps_ = loader_.contentLoaderInfo.frameRate;
    external_ = loader_.contentLoaderInfo.applicationDomain;
    var cl:Class = external_.getDefinition("test_shapes") as Class;
    var movie_clip:MovieClip = new cl();
    movie_clip.x = 200;
    movie_clip.y = 200;
    addChild(movie_clip);
    trace(movie_clip.numChildren);
    for (var f:int = 1; f <= movie_clip.totalFrames; ++f) {
      movie_clip.gotoAndStop(f);
      for (var c:int = 0; c < movie_clip.numChildren; ++c) {
        var child:DisplayObject = movie_clip.getChildAt(c);
        //child.parent.removeChild(child);
        trace(f, child.name, child.x);
        //var prev_x = child.x;
        child.scaleX = child.scaleY = 2;
        //child.x = prev_x;
        //movie_clip.addChild(child);
      }
    }
/*    for (var f:int = 1; f <= movie_clip.totalFrames; ++f) {
      movie_clip.gotoAndStop(f);
      for (var c:int = 0; c < movie_clip.numChildren; ++c) {
        var child:DisplayObject = movie_clip.getChildAt(c);
        //child.parent.removeChild(child);
        trace(f, child.name, child.x);
        //var prev_x = child.x;
        child.scaleX = child.scaleY = 2;
        //child.x = prev_x;
        //movie_clip.addChild(child);
      }
    }*/
    //var shape:Shape = movie_clip.getChildAt(0) as Shape;
    //var graph_data:Vector.<IGraphicsData> = shape.graphics.readGraphicsData();
    //shape.graphics.clear();
    //var vec:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
    //vec.push(graph_data[0], graph_data[1], graph_data[2]);
    //shape.graphics.drawGraphicsData(vec);
    //trace(graph_data.length);
    SaveExports();
    //var loader_info:LoaderInfo = e.currentTarget as LoaderInfo;
    //trace(getDefinitionByName("zombie_komikaze_miner_arm_down1"));
    //loader_.contentLoaderInfo.
    //trace(getDefinitionByName("zombie_komikaze_miner_arm_down1"));
    //var cc:MovieClip = getDefinitionByName("test_1_frame");
    //this.addChild(loader);
  }  

  private function SaveExports():void {
    /*var size:int = atlas_info_.exports.length;
    for (var i:int = 0; i < size; ++i) {
      var export:Object = atlas_info_.exports[i];
      var cl:Class = null;
      try {
        cl = external_.getDefinition(export.name) as Class;
      } catch (err:*) {
        throw new Error("class not found: '" + export.name + "'");
      }
      var obj:* = new cl();
      rendered_ = new Dictionary();
      class_name_ = export.name;
      curr_index_ = 0;
      SaveItem(obj, export.type);
      return;
    }*/
    //class_name_ = "test_1_frame";
    class_name_ = "anim_zombie";
    curr_index_ = 0;
    var cl:Class = external_.getDefinition(class_name_) as Class;
    var obj:* = new cl();
    //rendered_ = new Dictionary();
    var view_desc:Object = SaveItem(obj, null);
    var export_desc:Object = {};
    export_desc.name = "test/" + class_name_;
    export_desc.view_desc = view_desc;
    CleanViewDesc(export_desc.view_desc);
    SaveExportToFile(class_name_ + "/data.json", JSONer.stringify(export_desc));
  }

  private function SaveItem(obj:*, type:String):Object {
    //if (rendered_[GetName(obj)] != null) return;
    var view_desc:Object = {};
    if (type == null) type = GetType(obj);
    view_desc.type = type;
    trace("Save: '" + getQualifiedClassName(obj) + "'; type: '" + type + "'");
    switch(type) {
      case kImage: {
        var pivot:Point = SaveImage(obj);
        if (pivot != null) {
          view_desc.tex_name =  class_name_ + "/" + (curr_index_ - 1);
          //view_desc.name = GetName(obj);
          view_desc.pivot_x = -pivot.x;
          view_desc.pivot_y = -pivot.y;
        }
        break;
      }
      case kSprite: {
        view_desc.clip_desc = SaveSprite(obj);
        break;
      }
      case kParts: {
        view_desc.clip_desc = SaveParts(obj);
        break;
      }
      case kRaster: {
        view_desc.clip_desc = SaveRaster(obj);
        break;
      }
    }
    return view_desc;
    //if (getQualifiedSuperclassName(obj) == kBitmapData) return k
    //flash.utils.gte
  }

  //private function GetName(obj:*):String {
    //var dpo:DisplayObject = obj;
    //if (dpo != null) return dpo.name;
    //throw new Error("GetName");
    ////return getQualifiedClassName(obj);
  //}

  private function SaveImage(obj:*):Point {
    if (getQualifiedSuperclassName(obj) == kBitmapData) {
      
    } else {
      var dso:DisplayObject = obj;
      var no_transform_rc:Rectangle = dso.getBounds(null);
      var add_pixels:int = 10;
      //for (var i:int = 0; i < dso.filters.length; ++i) {
        //var val_x:Number = 0;
        //var val_y:Number = 0;
        //try {
          //val_x = dso.filters[i]["blurX"];
          //val_y = dso.filters[i]["blurY"];
        //} catch(err:*) {}
        //var to_add:Number = val_x;
        //if (to_add < val_y) to_add = val_y;
        //add_pixels += to_add * 1.2;
      //}
      var bounds_mtr:Matrix = dso.transform.matrix.clone();
      //bounds_mtr.rotate(-dso.rotation * Math.PI / 180);
      bounds_mtr.identity();
      var pnt_1:Point = bounds_mtr.transformPoint(
        new Point(no_transform_rc.x, no_transform_rc.y))
      var pnt_2:Point = bounds_mtr.transformPoint(
        new Point(no_transform_rc.right, no_transform_rc.y))
      var pnt_3:Point = bounds_mtr.transformPoint(
        new Point(no_transform_rc.right, no_transform_rc.bottom))
      var pnt_4:Point = bounds_mtr.transformPoint(
        new Point(no_transform_rc.x, no_transform_rc.bottom))
      
      var min_x:Number = Math.min(pnt_1.x, pnt_2.x, pnt_3.x, pnt_4.x);
      var max_x:Number = Math.max(pnt_1.x, pnt_2.x, pnt_3.x, pnt_4.x);
      var min_y:Number = Math.min(pnt_1.y, pnt_2.y, pnt_3.y, pnt_4.y);
      var max_y:Number = Math.max(pnt_1.y, pnt_2.y, pnt_3.y, pnt_4.y);
      
      var bounds_rc:Rectangle = new Rectangle(min_x, min_y,
        max_x - min_x, max_y - min_y);
      bounds_rc.x -= add_pixels;
      bounds_rc.y -= add_pixels;
      bounds_rc.width += add_pixels * 2;
      bounds_rc.height += add_pixels * 2;

      //bounds_rc.width = Math.ceil(bounds_rc.width);
      //bounds_rc.height = Math.ceil(bounds_rc.height);
      
      var prev_val:Number = bounds_rc.width;
      bounds_rc.width = Math.ceil(prev_val);
      bounds_rc.x += bounds_rc.width - prev_val;

      prev_val = bounds_rc.height;
      bounds_rc.height = Math.ceil(prev_val);
      bounds_rc.y += bounds_rc.height - prev_val;
      
      //bounds_rc.width = Math.ceil(bounds_rc.width);
      //bounds_rc.height = Math.ceil(bounds_rc.height);
      
      //bounds_rc = no_transform_rc.clone();
      
      if (bounds_rc.width == 0 || bounds_rc.height == 0) return null;
      var bd_full:BitmapData = new BitmapData(bounds_rc.width,
        bounds_rc.height, true, 0);
      //var matrix:Matrix = dso.transform.matrix.clone();
      //matrix.rotate(-dso.rotation * Math.PI / 180);
      var matrix:Matrix = new Matrix();
      matrix.tx -= bounds_rc.x;
      matrix.ty -= bounds_rc.y;
      matrix.tx = matrix.tx;
      matrix.ty = matrix.ty;
      bd_full.drawWithQuality(dso, matrix, null, null, null, true,
        StageQuality.BEST);
      //SaveByteArray(PNGEncoder.encode(bd_full));
      var cut_bounds:Rectangle = bd_full.getColorBoundsRect(0xFF000000,
        0x00000000, false);
      //cut_bounds = bd_full.rect.clone();
      if (cut_bounds.width == 0 || cut_bounds.height == 0) return null;
      var bd:BitmapData = new BitmapData(cut_bounds.width, cut_bounds.height,
        true, 0);
      bd.copyPixels(bd_full, cut_bounds, new Point());
      SaveByteArray(PNGEncoder.encode(bd));
      bounds_rc.x += cut_bounds.x;
      bounds_rc.y += cut_bounds.y;
    }
    //rendered_[GetName(obj)] = true;
    return new Point(bounds_rc.x, bounds_rc.y);
  }

  private function SavePartsFrameDesc(dsc:DisplayObjectContainer,
      clip_desc:Object):Object {
    var frame_desc:Object = {};
    var views_data:Array = new Array();
    frame_desc.views_data = views_data;
    var size:int = dsc.numChildren;
    for (var c:int = 0; c < size; ++c) {
      var child:DisplayObject = dsc.getChildAt(c);
      var name:String = GetUniqueName(child);
      var instance_index:int = GetInstance(clip_desc, child, name);
      var view_desc:Object = null;
      if (instance_index == -1) {
        view_desc = SaveItem(child, null);
        if (name.indexOf("instance") != 0) view_desc.name = name;
        clip_desc.views_desc.push(view_desc);
        clip_desc.instances_data_.push({
          instance: child,
          name: name
        });
        instance_index = clip_desc.views_desc.length - 1;
      } else {
        view_desc = clip_desc.views_desc[instance_index];
      }
      var mtr:Matrix = child.transform.matrix.clone();
      if (view_desc.type == kImage) {
        mtr.tx = mtr.tx - mtr.a * view_desc.pivot_x - mtr.c * view_desc.pivot_y;
        mtr.ty = mtr.ty - mtr.b * view_desc.pivot_x - mtr.d * view_desc.pivot_y;
      }
      var view_data:Object = {};
      if (mtr.a != 1 || mtr.b != 0 || mtr.c != 0 || mtr.d != 1 ||
          mtr.tx != 0 || mtr.ty != 0) {
        view_data.matrix = new Array(Trim(mtr.a), Trim(mtr.b), Trim(mtr.c),
          Trim(mtr.d), Trim(mtr.tx), Trim(mtr.ty));
        //view_data.matrix = new Array(mtr.a, mtr.b, mtr.c,
          //mtr.d, mtr.tx, mtr.ty);
      }
      view_data.index = instance_index;
      if (child.alpha < 1) view_data.alpha = child.alpha;
      views_data.push(view_data);
    }
    return frame_desc;
  }

  private function SaveRasterFrameDesc(mc:MovieClip, clip_desc:Object):Object {
    var frame_desc:Object = {};
    var views_data:Array = new Array();
    frame_desc.views_data = views_data;
    var name:String = GetUniqueName(mc) + "_" + mc.currentFrame;
    var instance_index:int = GetInstance(clip_desc, mc, name);
    var view_desc:Object = null;
    if (instance_index == -1) {
      view_desc = SaveItem(mc, kImage);
      clip_desc.views_desc.push(view_desc);
      clip_desc.instances_data_.push({
        instance: mc,
        name: name
      });
      instance_index = clip_desc.views_desc.length - 1;
    } else {
      view_desc = clip_desc.views_desc[instance_index];
    }
    //var mtr:Matrix = mc.transform.matrix.clone();
    var mtr:Matrix = new Matrix();
    //if (view_desc.type == kImage) {
      mtr.tx = -view_desc.pivot_x;
      mtr.ty = -view_desc.pivot_y;
    //}
    var view_data:Object = {};
    if (mtr.a != 1 || mtr.b != 0 || mtr.c != 0 || mtr.d != 1 ||
        mtr.tx != 0 || mtr.ty != 0) {
      view_data.matrix = new Array(Trim(mtr.a), Trim(mtr.b), Trim(mtr.c),
        Trim(mtr.d), Trim(mtr.tx), Trim(mtr.ty));
      //view_data.matrix = new Array(mtr.a, mtr.b, mtr.c,
        //mtr.d, mtr.tx, mtr.ty);
    }
    view_data.index = instance_index;
    views_data.push(view_data);
    return frame_desc;
  }

  private function GetUniqueName(dsc:DisplayObject):String {
    var obj_name:String = dsc.name;
    return obj_name;
  }
  
  private function GetInstance(clip_desc:Object, instance:Object,
      name:String):int {
    for (var i:int = 0; i < clip_desc.instances_data_.length; ++i) {
      var instance_data:Object = clip_desc.instances_data_[i];
      if (instance_data.instance == instance &&
          instance_data.name == name) return i;
    }
    return -1;
  }
  
  private function SaveSprite(dsc:DisplayObjectContainer):Object {
    var clip_desc:Object = {};
    clip_desc.fps = fps_;
    clip_desc.instances_data_ = new Array();
    clip_desc.frames_desc = new Array();
    clip_desc.views_desc = new Array();
    clip_desc.frames_desc.push(SavePartsFrameDesc(dsc, clip_desc));
    return clip_desc;
  }

  private function SaveParts(dsc:DisplayObjectContainer):Object {
    var clip_desc:Object = {};
    clip_desc.fps = fps_;
    clip_desc.instances_data_ = new Array();
    clip_desc.frames_desc = new Array();
    clip_desc.views_desc = new Array();
    var mc:MovieClip = dsc as MovieClip;
    for (var i:int = 1; i <= mc.totalFrames; ++i) {
      mc.gotoAndStop(i);
      clip_desc.frames_desc.push(SavePartsFrameDesc(mc, clip_desc));
    }
    return clip_desc;
  }

  private function SaveRaster(dsc:DisplayObjectContainer):Object {
    var clip_desc:Object = {};
    clip_desc.fps = fps_;
    clip_desc.instances_data_ = new Array();
    clip_desc.frames_desc = new Array();
    clip_desc.views_desc = new Array();
    var mc:MovieClip = dsc as MovieClip;
    for (var i:int = 1; i <= mc.totalFrames; ++i) {
      mc.gotoAndStop(i);
      clip_desc.frames_desc.push(SaveRasterFrameDesc(mc, clip_desc));
    }
    return clip_desc;
  }

  private function CnvType(obj:*, flash_type:String):String {
    if (flash_type == kBitmapData) return kImage;
    if (flash_type == kMovieClip) {
      var mc:MovieClip = obj;
      var shapes_only:Boolean = true;
      for (var i:int = 0; i < mc.totalFrames; ++i) {
        mc.gotoAndStop(i);
        for (var c:int = 0; c < mc.numChildren; ++c) {
          if ((mc.getChildAt(c) as Shape) == null) {
            shapes_only = false;
            break;
          }
        }
      }
      mc.gotoAndStop(1);
      if (mc.totalFrames == 1) {
        if (shapes_only) return kImage;
        return kSprite;
      }
      if (shapes_only) return kRaster;
      return kParts;
    }
    return kNone;
  }
  
  private function GetType(obj:*):String {
    var type:String = CnvType(obj, getQualifiedClassName(obj));
    if (type != kNone) return type;
    type = CnvType(obj, getQualifiedSuperclassName(obj));
    if (type != kNone) return type;
    return kImage;
  }

  private function SaveByteArray(ba:ByteArray):void {
    try {
      var file_dir_path:String = out_dir_ + "/" + class_name_;
      var file_dir:File = new File(file_dir_path);
      file_dir.createDirectory();
      var file_path:String = file_dir_path + "/" + curr_index_ + ".png";
      ++curr_index_;
      var file:File = new File(file_path);
      var file_stream:FileStream = new FileStream(); 
      file_stream.open(file, FileMode.WRITE);
      file_stream.writeBytes(ba);
      file_stream.close();
    } catch (err:*) {
      throw new Error("write file: '" + file_path + "'");
    }
  }

  private function ReadFileAsByteArray(path:String):ByteArray {
    try {
      var file:File = new File(path);
      var file_stream:FileStream = new FileStream(); 
      file_stream.open(file, FileMode.READ);
      var byte_array:ByteArray = new ByteArray();
      file_stream.readBytes(byte_array);
      file_stream.close();
      return byte_array;
    } catch (err:*) {
      throw new Error("opening file: '" + path + "'");
    }
  }

  private function ReadFileAsString(path:String):String {
    var byte_array:ByteArray = ReadFileAsByteArray(path);
    return byte_array.readUTFBytes(byte_array.length);
  }

  private function SaveExportToFile(rel_path:String, data:String):void {
    try {
      //var file_dir_path:String = out_dir_ + rel_path;
      //var file_dir:File = new File(file_dir_path);
      //file_dir.createDirectory();
      var file_path:String = out_dir_ + "/" + rel_path;
      var file:File = new File(file_path);
      var file_stream:FileStream = new FileStream(); 
      file_stream.open(file, FileMode.WRITE);
      file_stream.writeUTFBytes(data);
      file_stream.close();
    } catch (err:*) {
      throw new Error("SaveStringToFile: '" + name + "'");
    }
  }

  public function Trim(number:Number):Number {
    return Math.round(number * 10000) / 10000;
  }
  
  public function CleanViewDesc(view_desc:Object):void {
    if (view_desc.type == kImage) return;
    if (view_desc.type == kSprite ||
        view_desc.type == kParts ||
        view_desc.type == kRaster) {
      var clip_desc:Object = view_desc.clip_desc;
      delete clip_desc["instances_data_"];
      var views_desc:Array = clip_desc.views_desc;
      for (var i:int = 0; i < views_desc.length; ++i) {
        CleanViewDesc(views_desc[i]);
      }
    }
  }
  
/*  private function OnComplete(e:Event):void {
    trace(123);
    external_ = loader_.contentLoaderInfo.applicationDomain;
    var cl:Class = external_.getDefinition("AnEnemyZombieKamikazeMinerActions1") as Class;
    var movie_clip:MovieClip = new cl();
    movie_clip.x = 200;
    movie_clip.y = 200;
    addChild(movie_clip);
    trace(movie_clip.totalFrames);
    //var loader_info:LoaderInfo = e.currentTarget as LoaderInfo;
    //trace(getDefinitionByName("zombie_komikaze_miner_arm_down1"));
    //loader_.contentLoaderInfo.
    //trace(getDefinitionByName("zombie_komikaze_miner_arm_down1"));
    //var cc:MovieClip = getDefinitionByName("test_1_frame");
    //this.addChild(loader);
  }
*/  

  //protected static const kArgumentsRegExp:RegExp = /(--[a-z]*)=(.*)/i;

  private static const kNone:String = "none";
  private static const kParts:String = "parts";
  private static const kRaster:String = "raster";
  private static const kImage:String = "image";
  private static const kSprite:String = "sprite";

  private static const kBitmapData:String =
    getQualifiedClassName(new BitmapData(1, 1));
  private static const kMovieClip:String =
    getQualifiedClassName(new MovieClip());
  private static const kShape:String =
    getQualifiedClassName(new Shape());
  //private static const kFlashSprite:String =
    //getQualifiedClassName(new Sprite());
  
  private var swf_path_:String = null;
  private var descr_path_:String = null;
  private var out_dir_:String = null;
  //private var scale_:Number = 1;

  private var descr_:Object = null;

  private var loader_:Loader = null;
  private var external_:ApplicationDomain = null;
  private var fps_:int = 0;
  
  //private var rendered_:Dictionary = new Dictionary();
  private var curr_index_:int = 0;
  private var class_name_:String = null;
  //private var curr_indexexternal_:ApplicationDomain = null;

}
}
