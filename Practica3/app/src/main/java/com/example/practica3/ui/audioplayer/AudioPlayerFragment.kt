package com.example.practica3.ui.audioplayer

import android.content.Intent
import android.media.MediaPlayer
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.SeekBar
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.recyclerview.widget.LinearLayoutManager
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import com.google.android.material.snackbar.Snackbar
import com.tuuniversidad.camapp.databinding.FragmentAudioPlayerBinding
import java.text.SimpleDateFormat
import java.util.*

class AudioPlayerFragment : Fragment() {

    private var _binding: FragmentAudioPlayerBinding? = null
    private val binding get() = _binding!!
    private val viewModel: AudioPlayerViewModel by viewModels()

    private lateinit var audioAdapter: AudioAdapter
    private var mediaPlayer: MediaPlayer? = null
    private var currentAudioUri: Uri? = null
    private var isPlaying = false

    private val handler = Handler(Looper.getMainLooper())
    private val updateProgressRunnable = object : Runnable {
        override fun run() {
            updateProgress()
            if (isPlaying) {
                handler.postDelayed(this, 100)
            }
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentAudioPlayerBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupRecyclerView()
        setupControls()
        observeViewModel()
    }

    private fun setupRecyclerView() {
        audioAdapter = AudioAdapter(
            onAudioClick = { audio ->
                playAudio(audio)
            },
            onAudioLongClick = { audio ->
                showAudioOptions(audio)
            }
        )

        binding.recyclerView.apply {
            layoutManager = LinearLayoutManager(requireContext())
            adapter = audioAdapter
            setHasFixedSize(true)
        }
    }

    private fun setupControls() {
        // Controles de reproducción
        binding.btnPlayPause.setOnClickListener {
            if (isPlaying) {
                pauseAudio()
            } else {
                resumeAudio()
            }
        }

        binding.btnStop.setOnClickListener {
            stopAudio()
        }

        binding.btnRewind.setOnClickListener {
            seekBackward()
        }

        binding.btnForward.setOnClickListener {
            seekForward()
        }

        // SeekBar
        binding.seekBar.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                if (fromUser) {
                    mediaPlayer?.seekTo(progress)
                    updateTimeLabels(progress)
                }
            }

            override fun onStartTrackingTouch(seekBar: SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        })

        // Velocidad de reproducción
        binding.btnSpeed.setOnClickListener {
            showSpeedDialog()
        }

        // Compartir
        binding.btnShare.setOnClickListener {
            shareCurrentAudio()
        }

        // Eliminar
        binding.btnDelete.setOnClickListener {
            confirmDeleteCurrent()
        }

        // Renombrar
        binding.btnRename.setOnClickListener {
            showRenameDialog()
        }
    }

    private fun playAudio(audio: com.tuuniversidad.camapp.data.database.AudioEntity) {
        try {
            // Liberar reproductor anterior
            releaseMediaPlayer()

            val uri = Uri.parse(audio.uri)
            currentAudioUri = uri

            mediaPlayer = MediaPlayer().apply {
                setDataSource(requireContext(), uri)
                prepare()

                setOnCompletionListener {
                    onAudioCompleted()
                }

                start()
            }

            isPlaying = true
            updatePlayerUI(audio)
            handler.post(updateProgressRunnable)

            // Actualizar visualización de forma de onda
            viewModel.loadWaveform(audio.uri)

        } catch (e: Exception) {
            showError("Error al reproducir: ${e.message}")
        }
    }

    private fun pauseAudio() {
        mediaPlayer?.pause()
        isPlaying = false
        binding.btnPlayPause.setImageResource(android.R.drawable.ic_media_play)
        handler.removeCallbacks(updateProgressRunnable)
    }

    private fun resumeAudio() {
        mediaPlayer?.start()
        isPlaying = true
        binding.btnPlayPause.setImageResource(android.R.drawable.ic_media_pause)
        handler.post(updateProgressRunnable)
    }

    private fun stopAudio() {
        releaseMediaPlayer()
        isPlaying = false
        binding.btnPlayPause.setImageResource(android.R.drawable.ic_media_play)
        binding.seekBar.progress = 0
        binding.tvCurrentTime.text = "00:00"
        handler.removeCallbacks(updateProgressRunnable)
    }

    private fun seekBackward() {
        mediaPlayer?.let { player ->
            val newPosition = (player.currentPosition - 5000).coerceAtLeast(0)
            player.seekTo(newPosition)
        }
    }

    private fun seekForward() {
        mediaPlayer?.let { player ->
            val newPosition = (player.currentPosition + 5000).coerceAtMost(player.duration)
            player.seekTo(newPosition)
        }
    }

    private fun updateProgress() {
        mediaPlayer?.let { player ->
            val currentPosition = player.currentPosition
            val duration = player.duration

            binding.seekBar.max = duration
            binding.seekBar.progress = currentPosition

            updateTimeLabels(currentPosition)

            // Actualizar indicador en la forma de onda
            binding.waveformView.updatePlaybackPosition(currentPosition.toFloat() / duration)
        }
    }

    private fun updateTimeLabels(currentPosition: Int) {
        binding.tvCurrentTime.text = formatTime(currentPosition)
        mediaPlayer?.let { player ->
            binding.tvTotalTime.text = formatTime(player.duration)
        }
    }

    private fun formatTime(milliseconds: Int): String {
        val seconds = (milliseconds / 1000) % 60
        val minutes = (milliseconds / (1000 * 60)) % 60
        val hours = (milliseconds / (1000 * 60 * 60))

        return if (hours > 0) {
            String.format("%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            String.format("%02d:%02d", minutes, seconds)
        }
    }

    private fun updatePlayerUI(audio: com.tuuniversidad.camapp.data.database.AudioEntity) {
        binding.tvAudioTitle.text = extractFileName(audio.uri)
        binding.tvDuration.text = formatTime(audio.duration.toInt() * 1000)
        binding.tvFileSize.text = formatFileSize(audio.fileSize)
        binding.tvQuality.text = audio.quality
        binding.btnPlayPause.setImageResource(android.R.drawable.ic_media_pause)

        // Mostrar fecha
        val date = Date(audio.timestamp)
        binding.tvDate.text = SimpleDateFormat("dd/MM/yyyy HH:mm", Locale.getDefault()).format(date)
    }

    private fun extractFileName(uri: String): String {
        return uri.substringAfterLast("/").substringBeforeLast(".")
    }

    private fun formatFileSize(bytes: Long): String {
        return when {
            bytes < 1024 -> "$bytes B"
            bytes < 1024 * 1024 -> String.format("%.2f KB", bytes / 1024.0)
            else -> String.format("%.2f MB", bytes / (1024.0 * 1024.0))
        }
    }

    private fun onAudioCompleted() {
        isPlaying = false
        binding.btnPlayPause.setImageResource(android.R.drawable.ic_media_play)
        binding.seekBar.progress = 0
        handler.removeCallbacks(updateProgressRunnable)

        // Auto-reproducir siguiente si está habilitado
        if (viewModel.isAutoPlayEnabled.value == true) {
            viewModel.playNextAudio()
        }
    }

    private fun showSpeedDialog() {
        val speeds = arrayOf("0.5x", "0.75x", "Normal", "1.25x", "1.5x", "2x")

        MaterialAlertDialogBuilder(requireContext())
            .setTitle("Velocidad de reproducción")
            .setItems(speeds) { _, which ->
                val speed = when (which) {
                    0 -> 0.5f
                    1 -> 0.75f
                    2 -> 1.0f
                    3 -> 1.25f
                    4 -> 1.5f
                    5 -> 2.0f
                    else -> 1.0f
                }

                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                    mediaPlayer?.playbackParams = mediaPlayer?.playbackParams?.setSpeed(speed)!!
                    binding.btnSpeed.text = speeds[which]
                }
            }
            .show()
    }

    private fun shareCurrentAudio() {
        currentAudioUri?.let { uri ->
            val shareIntent = Intent().apply {
                action = Intent.ACTION_SEND
                type = "audio/*"
                putExtra(Intent.EXTRA_STREAM, uri)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            startActivity(Intent.createChooser(shareIntent, "Compartir audio"))
        }
    }

    private fun confirmDeleteCurrent() {
        MaterialAlertDialogBuilder(requireContext())
            .setTitle("Eliminar audio")
            .setMessage("¿Estás seguro de que deseas eliminar esta grabación?")
            .setPositiveButton("Eliminar") { _, _ ->
                viewModel.deleteCurrentAudio()
                stopAudio()
                showSuccess("Audio eliminado")
            }
            .setNegativeButton("Cancelar", null)
            .show()
    }

    private fun showRenameDialog() {
        val input = android.widget.EditText(requireContext()).apply {
            setText(extractFileName(currentAudioUri.toString()))
        }

        MaterialAlertDialogBuilder(requireContext())
            .setTitle("Renombrar audio")
            .setView(input)
            .setPositiveButton("Renombrar") { _, _ ->
                val newName = input.text.toString()
                if (newName.isNotBlank()) {
                    viewModel.renameCurrentAudio(newName)
                    showSuccess("Audio renombrado")
                }
            }
            .setNegativeButton("Cancelar", null)
            .show()
    }

    private fun showAudioOptions(audio: com.tuuniversidad.camapp.data.database.AudioEntity) {
        val options = arrayOf("Reproducir", "Compartir", "Renombrar", "Agregar a álbum", "Eliminar")

        MaterialAlertDialogBuilder(requireContext())
            .setTitle("Opciones")
            .setItems(options) { _, which ->
                when (which) {
                    0 -> playAudio(audio)
                    1 -> shareAudio(audio)
                    2 -> showRenameDialogForAudio(audio)
                    3 -> showMoveToAlbumDialog(audio)
                    4 -> confirmDeleteAudio(audio)
                }
            }
            .show()
    }

    private fun shareAudio(audio: com.tuuniversidad.camapp.data.database.AudioEntity) {
        val uri = Uri.parse(audio.uri)
        val shareIntent = Intent().apply {
            action = Intent.ACTION_SEND
            type = "audio/*"
            putExtra(Intent.EXTRA_STREAM, uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        startActivity(Intent.createChooser(shareIntent, "Compartir audio"))
    }

    private fun showRenameDialogForAudio(audio: com.tuuniversidad.camapp.data.database.AudioEntity) {
        val input = android.widget.EditText(requireContext()).apply {
            setText(extractFileName(audio.uri))
        }

        MaterialAlertDialogBuilder(requireContext())
            .setTitle("Renombrar audio")
            .setView(input)
            .setPositiveButton("Renombrar") { _, _ ->
                val newName = input.text.toString()
                if (newName.isNotBlank()) {
                    viewModel.renameAudio(audio.id, newName)
                    showSuccess("Audio renombrado")
                }
            }
            .setNegativeButton("Cancelar", null)
            .show()
    }

    private fun showMoveToAlbumDialog(audio: com.tuuniversidad.camapp.data.database.AudioEntity) {
        viewModel.albums.value?.let { albums ->
            val albumNames = albums.map { it.name }.toTypedArray()

            MaterialAlertDialogBuilder(requireContext())
                .setTitle("Mover a álbum")
                .setItems(albumNames) { _, which ->
                    val albumId = albums[which].id
                    viewModel.moveAudioToAlbum(audio.id, albumId)
                    showSuccess("Audio movido al álbum")
                }
                .show()
        }
    }

    private fun confirmDeleteAudio(audio: com.tuuniversidad.camapp.data.database.AudioEntity) {
        MaterialAlertDialogBuilder(requireContext())
            .setTitle("Eliminar audio")
            .setMessage("¿Estás seguro de que deseas eliminar esta grabación?")
            .setPositiveButton("Eliminar") { _, _ ->
                viewModel.deleteAudio(audio.id)
                if (currentAudioUri.toString() == audio.uri) {
                    stopAudio()
                }
                showSuccess("Audio eliminado")
            }
            .setNegativeButton("Cancelar", null)
            .show()
    }

    private fun observeViewModel() {
        viewModel.audioList.observe(viewLifecycleOwner) { audioList ->
            audioAdapter.submitList(audioList)
            binding.tvEmpty.visibility = if (audioList.isEmpty()) View.VISIBLE else View.GONE
        }

        viewModel.waveformData.observe(viewLifecycleOwner) { waveform ->
            binding.waveformView.setWaveform(waveform)
        }
    }

    private fun releaseMediaPlayer() {
        try {
            mediaPlayer?.release()
            mediaPlayer = null
        } catch (e: Exception) {
            // Ignorar errores al liberar
        }
    }

    private fun showSuccess(message: String) {
        Snackbar.make(binding.root, message, Snackbar.LENGTH_SHORT).show()
    }

    private fun showError(message: String) {
        Snackbar.make(binding.root, message, Snackbar.LENGTH_LONG).show()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        stopAudio()
        handler.removeCallbacks(updateProgressRunnable)
        _binding = null
    }

    override fun onPause() {
        super.onPause()
        pauseAudio()
    }
}