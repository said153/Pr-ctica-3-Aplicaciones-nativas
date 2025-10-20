package com.example.practica3.ui.audioplayer

import android.net.Uri
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.example.practica3.data.database.AudioEntity
import com.example.practica3.data.databinding.ItemAudioBinding
import java.text.SimpleDateFormat
import java.util.*

class AudioAdapter(
    private val onAudioClick: (AudioEntity) -> Unit,
    private val onAudioLongClick: (AudioEntity) -> Unit
) : ListAdapter<AudioEntity, AudioAdapter.AudioViewHolder>(AudioDiffCallback()) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): AudioViewHolder {
        val binding = ItemAudioBinding.inflate(
            LayoutInflater.from(parent.context),
            parent,
            false
        )
        return AudioViewHolder(binding)
    }

    override fun onBindViewHolder(holder: AudioViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    inner class AudioViewHolder(
        private val binding: ItemAudioBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(audio: AudioEntity) {
            // Extraer nombre del archivo
            val fileName = Uri.parse(audio.uri)
                .lastPathSegment
                ?.substringBeforeLast(".") ?: "Audio"

            binding.tvTitle.text = fileName

            // Formatear duración
            val minutes = audio.duration / 60
            val seconds = audio.duration % 60
            binding.tvDuration.text = String.format("%02d:%02d", minutes, seconds)

            // Formatear tamaño
            binding.tvFileSize.text = formatFileSize(audio.fileSize)

            // Formatear fecha
            val date = Date(audio.timestamp)
            val dateFormat = SimpleDateFormat("dd/MM/yyyy HH:mm", Locale.getDefault())
            binding.tvDate.text = dateFormat.format(date)

            // Calidad
            binding.tvQuality.text = audio.quality

            // Indicador de favorito
            binding.favoriteIcon.visibility = if (audio.isFavorite)
                android.view.View.VISIBLE else android.view.View.GONE

            // Listeners
            binding.root.setOnClickListener {
                onAudioClick(audio)
            }

            binding.root.setOnLongClickListener {
                onAudioLongClick(audio)
                true
            }
        }

        private fun formatFileSize(bytes: Long): String {
            return when {
                bytes < 1024 -> "$bytes B"
                bytes < 1024 * 1024 -> String.format("%.2f KB", bytes / 1024.0)
                else -> String.format("%.2f MB", bytes / (1024.0 * 1024.0))
            }
        }
    }

    private class AudioDiffCallback : DiffUtil.ItemCallback<AudioEntity>() {
        override fun areItemsTheSame(oldItem: AudioEntity, newItem: AudioEntity): Boolean {
            return oldItem.id == newItem.id
        }

        override fun areContentsTheSame(oldItem: AudioEntity, newItem: AudioEntity): Boolean {
            return oldItem == newItem
        }
    }
}