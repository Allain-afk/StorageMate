package app.storagemate.storagemate

import android.content.Context
import android.os.Build
import android.os.StatFs
import android.os.Environment
import android.os.storage.StorageManager
import android.provider.MediaStore
import android.database.Cursor
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Platform channel for accessing Android storage APIs.
 * Provides device storage statistics and MediaStore access.
 */
class StorageChannel(private val context: Context, flutterEngine: FlutterEngine) {
    
    companion object {
        private const val CHANNEL = "app.storagemate/storage"
    }

    init {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getStorageStats" -> {
                    try {
                        result.success(getStorageStats())
                    } catch (e: Exception) {
                        result.error("STORAGE_ERROR", e.message, null)
                    }
                }
                "getMediaFiles" -> {
                    try {
                        val type = call.argument<String>("type") ?: "all"
                        result.success(getMediaFiles(type))
                    } catch (e: Exception) {
                        result.error("MEDIA_ERROR", e.message, null)
                    }
                }
                "getCategoryBreakdown" -> {
                    try {
                        result.success(getCategoryBreakdown())
                    } catch (e: Exception) {
                        result.error("CATEGORY_ERROR", e.message, null)
                    }
                }
                "getExternalStoragePath" -> {
                    result.success(Environment.getExternalStorageDirectory().absolutePath)
                }
                "getDownloadsPath" -> {
                    result.success(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).absolutePath)
                }
                else -> result.notImplemented()
            }
        }
    }

    /**
     * Get storage statistics using StatFs.
     * Returns total, used, and free space in bytes.
     */
    private fun getStorageStats(): Map<String, Any> {
        val path = Environment.getDataDirectory()
        val stat = StatFs(path.path)
        
        val blockSize = stat.blockSizeLong
        val totalBlocks = stat.blockCountLong
        val availableBlocks = stat.availableBlocksLong
        
        val totalBytes = totalBlocks * blockSize
        val freeBytes = availableBlocks * blockSize
        val usedBytes = totalBytes - freeBytes
        
        // Get external storage stats
        val externalPath = Environment.getExternalStorageDirectory()
        val externalStat = StatFs(externalPath.path)
        val externalBlockSize = externalStat.blockSizeLong
        val externalTotalBlocks = externalStat.blockCountLong
        val externalAvailableBlocks = externalStat.availableBlocksLong
        
        val externalTotalBytes = externalTotalBlocks * externalBlockSize
        val externalFreeBytes = externalAvailableBlocks * externalBlockSize
        val externalUsedBytes = externalTotalBytes - externalFreeBytes
        
        return mapOf(
            "internal" to mapOf(
                "totalBytes" to totalBytes,
                "usedBytes" to usedBytes,
                "freeBytes" to freeBytes
            ),
            "external" to mapOf(
                "totalBytes" to externalTotalBytes,
                "usedBytes" to externalUsedBytes,
                "freeBytes" to externalFreeBytes
            )
        )
    }

    /**
     * Get media files from MediaStore.
     * Type can be: "images", "videos", "audio", or "all"
     */
    private fun getMediaFiles(type: String): List<Map<String, Any>> {
        val files = mutableListOf<Map<String, Any>>()
        
        val projections = arrayOf(
            MediaStore.MediaColumns._ID,
            MediaStore.MediaColumns.DISPLAY_NAME,
            MediaStore.MediaColumns.SIZE,
            MediaStore.MediaColumns.DATE_MODIFIED,
            MediaStore.MediaColumns.MIME_TYPE,
            MediaStore.MediaColumns.DATA
        )
        
        val collections = when (type) {
            "images" -> listOf(MediaStore.Images.Media.EXTERNAL_CONTENT_URI)
            "videos" -> listOf(MediaStore.Video.Media.EXTERNAL_CONTENT_URI)
            "audio" -> listOf(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI)
            else -> listOf(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
            )
        }
        
        for (collection in collections) {
            var cursor: Cursor? = null
            try {
                cursor = context.contentResolver.query(
                    collection,
                    projections,
                    null,
                    null,
                    "${MediaStore.MediaColumns.DATE_MODIFIED} DESC"
                )
                
                cursor?.use {
                    val idColumn = it.getColumnIndexOrThrow(MediaStore.MediaColumns._ID)
                    val nameColumn = it.getColumnIndexOrThrow(MediaStore.MediaColumns.DISPLAY_NAME)
                    val sizeColumn = it.getColumnIndexOrThrow(MediaStore.MediaColumns.SIZE)
                    val dateColumn = it.getColumnIndexOrThrow(MediaStore.MediaColumns.DATE_MODIFIED)
                    val mimeColumn = it.getColumnIndexOrThrow(MediaStore.MediaColumns.MIME_TYPE)
                    val dataColumn = it.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA)
                    
                    while (it.moveToNext()) {
                        val id = it.getLong(idColumn)
                        val name = it.getString(nameColumn)
                        val size = it.getLong(sizeColumn)
                        val dateModified = it.getLong(dateColumn)
                        val mimeType = it.getString(mimeColumn) ?: ""
                        val path = it.getString(dataColumn)
                        
                        files.add(mapOf(
                            "id" to id.toString(),
                            "name" to name,
                            "path" to path,
                            "size" to size,
                            "mimeType" to mimeType,
                            "lastModified" to dateModified * 1000 // Convert to milliseconds
                        ))
                    }
                }
            } catch (e: Exception) {
                // Log error but continue with other collections
                android.util.Log.e("StorageChannel", "Error querying MediaStore: ${e.message}")
            } finally {
                cursor?.close()
            }
        }
        
        return files
    }

    /**
     * Get category breakdown of storage usage.
     * Returns size in bytes for each category.
     */
    private fun getCategoryBreakdown(): Map<String, Long> {
        val categories = mutableMapOf(
            "images" to 0L,
            "videos" to 0L,
            "audio" to 0L,
            "documents" to 0L,
            "apks" to 0L,
            "downloads" to 0L,
            "cache" to 0L,
            "other" to 0L
        )
        
        // Get images size
        categories["images"] = getMediaCategorySize(MediaStore.Images.Media.EXTERNAL_CONTENT_URI)
        
        // Get videos size
        categories["videos"] = getMediaCategorySize(MediaStore.Video.Media.EXTERNAL_CONTENT_URI)
        
        // Get audio size
        categories["audio"] = getMediaCategorySize(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI)
        
        // Get downloads size
        val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        if (downloadsDir.exists()) {
            categories["downloads"] = calculateDirectorySize(downloadsDir)
        }
        
        // Get APK files size
        categories["apks"] = getApkFilesSize()
        
        // Get cache size
        val cacheDir = context.cacheDir
        if (cacheDir.exists()) {
            categories["cache"] = calculateDirectorySize(cacheDir)
        }
        
        return categories
    }

    /**
     * Get total size of media files in a MediaStore collection.
     */
    private fun getMediaCategorySize(uri: android.net.Uri): Long {
        var totalSize = 0L
        var cursor: Cursor? = null
        
        try {
            cursor = context.contentResolver.query(
                uri,
                arrayOf(MediaStore.MediaColumns.SIZE),
                null,
                null,
                null
            )
            
            cursor?.use {
                val sizeColumn = it.getColumnIndexOrThrow(MediaStore.MediaColumns.SIZE)
                while (it.moveToNext()) {
                    totalSize += it.getLong(sizeColumn)
                }
            }
        } catch (e: Exception) {
            android.util.Log.e("StorageChannel", "Error calculating category size: ${e.message}")
        } finally {
            cursor?.close()
        }
        
        return totalSize
    }

    /**
     * Calculate total size of all APK files.
     */
    private fun getApkFilesSize(): Long {
        var totalSize = 0L
        var cursor: Cursor? = null
        
        try {
            val projection = arrayOf(
                MediaStore.Files.FileColumns._ID,
                MediaStore.Files.FileColumns.SIZE
            )
            
            val selection = "${MediaStore.Files.FileColumns.MIME_TYPE} = ?"
            val selectionArgs = arrayOf("application/vnd.android.package-archive")
            
            cursor = context.contentResolver.query(
                MediaStore.Files.getContentUri("external"),
                projection,
                selection,
                selectionArgs,
                null
            )
            
            cursor?.use {
                val sizeColumn = it.getColumnIndexOrThrow(MediaStore.Files.FileColumns.SIZE)
                while (it.moveToNext()) {
                    totalSize += it.getLong(sizeColumn)
                }
            }
        } catch (e: Exception) {
            android.util.Log.e("StorageChannel", "Error calculating APK size: ${e.message}")
        } finally {
            cursor?.close()
        }
        
        return totalSize
    }

    /**
     * Recursively calculate directory size.
     */
    private fun calculateDirectorySize(directory: File): Long {
        var size = 0L
        
        try {
            val files = directory.listFiles()
            if (files != null) {
                for (file in files) {
                    size += if (file.isDirectory) {
                        calculateDirectorySize(file)
                    } else {
                        file.length()
                    }
                }
            }
        } catch (e: Exception) {
            android.util.Log.e("StorageChannel", "Error calculating directory size: ${e.message}")
        }
        
        return size
    }
}

