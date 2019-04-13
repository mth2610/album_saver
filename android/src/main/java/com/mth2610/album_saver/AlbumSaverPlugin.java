package com.mth2610.album_saver;

import android.app.Activity;
import android.util.Log;

import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import android.media.MediaScannerConnection;
import android.media.MediaScannerConnection.MediaScannerConnectionClient;
import android.net.Uri;

import android.os.Environment;
import android.content.Context;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import java.io.File;
import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.io.InputStream;

/** AlbumSaverPlugin */
public class AlbumSaverPlugin implements MethodCallHandler {
  private final Activity activity;
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "album_saver");
    channel.setMethodCallHandler(new AlbumSaverPlugin(registrar.activity()));
  }

  private AlbumSaverPlugin(Activity activity) {
    this.activity = activity;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("saveToAlbum")) {
      String filePath = call.argument("filePath");
      String albumName = call.argument("albumName");
      saveToAlbum(filePath, albumName, result);
    } else if (call.method.equals("createAlbum")) {
      String albumName = call.argument("albumName");
      createAlbum(albumName, result);
    } else if (call.method.equals("getDcimPath")) {
      getDcimPath(result);
    }else {
      result.notImplemented();
    }
  }

  private void saveToAlbum(final String filePath, final String albumName, final Result result){
    new Thread(new Runnable() {
      public void run() {
       try {
        InputStream in;
        String root = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM).toString()+ "/"+albumName;
        File myDir = new File(root);
        myDir.mkdirs();
        String fname = String.valueOf(System.currentTimeMillis()) + ".png";
        File file = new File(myDir, fname);
        if (file.exists()) file.delete();
        try {
            FileOutputStream out = new FileOutputStream(file);
            in = new FileInputStream(filePath);        
            byte[] buffer = new byte[1024];
            int read;
            while ((read = in.read(buffer)) != -1) {
                out.write(buffer, 0, read);
            }
            in.close();
            in = null;
            // write the output file
            out.flush();
            out.close();
            out = null;
            result.success(file.getAbsolutePath());
            // MediaScannerConnection.scanFile(this.activity,
            //   new String[] { file.getAbsolutePath() }, null,
            //   new MediaScannerConnection.OnScanCompletedListener() {
            //     public void onScanCompleted(String path, Uri uri) {
            //         Log.i("TAG", "Finished scanning " + path);
            //     }
            // });
        } catch (Exception e) {
            e.printStackTrace();
        }
       } catch (Exception e) {
        e.printStackTrace();
       }
      }
     }).start();
  }
  private void createAlbum(final String albumName, final Result result){
    new Thread(new Runnable() {
      public void run() {
        String root = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM).toString()+ "/"+albumName;
        File myDir = new File(root);
        myDir.mkdirs();
        result.success(myDir.getAbsolutePath());
      }
    }).start();
  }

  private void getDcimPath(final Result result){
    new Thread(new Runnable() {
      public void run() {
        String root = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM).toString();
        result.success(root);
      }
    }).start();
  }
}
