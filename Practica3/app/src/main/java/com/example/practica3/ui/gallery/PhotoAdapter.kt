package com.example.practica3.ui.gallery

import android.net.Uri
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.tuuniversidad.camapp.R
import com.tuuniversidad.camapp.data.database.PhotoEntity
import com.tuuniversidad.camapp.databinding.ItemPhotoBinding

class PhotoAdapter(
    private val onPhotoClick: (PhotoEntity) -> Unit,
    private val onPhotoLongClick: (PhotoEntity) -> Unit
) : ListAdapter<PhotoEntity, PhotoAdapter.PhotoViewHolder>(PhotoDiffCallback()) {

    private var isSelectionMode = false
    private val selectedPhotos = mutableSetOf<Long>()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): PhotoViewHolder {
        val binding = ItemPhotoBinding.inflate(
            LayoutInflater.from(parent.context),
            parent,
            false
        )
        return PhotoViewHolder(binding)
    }

    override fun onBindViewHolder(holder: PhotoViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    fun setSelectionMode(enabled: Boolean) {
        isSelectionMode = enabled
        if (!enabled) {
            selectedPhotos.clear()
        }
        notifyDataSetChanged()
    }

    fun updateSelection(selected: Set<Long>) {
        selectedPhotos.clear()
        selectedPhotos.addAll(selected)
        notifyDataSetChanged()
    }

    fun clearSelection() {
        selectedPhotos.clear()
        notifyDataSetChanged()
    }

    inner class PhotoViewHolder(
        private val binding: ItemPhotoBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(photo: PhotoEntity) {
            // Cargar imagen con Glide
            Glide.with(binding.root.context)
                .load(Uri.parse(photo.uri))
                .centerCrop()
                .placeholder(R.drawable.ic_image_placeholder)
                .error(R.drawable.ic_image_error)
                .into(binding.imageView)

            // Mostrar indicadores
            binding.favoriteIcon.visibility = if (photo.isFavorite)
                android.view.View.VISIBLE else android.view.View.GONE

            binding.filterIcon.visibility = if (photo.filterApplied != null)
                android.view.View.VISIBLE else android.view.View.GONE

            // Modo selección
            if (isSelectionMode) {
                binding.selectionOverlay.visibility = android.view.View.VISIBLE
                binding.checkBox.visibility = android.view.View.VISIBLE
                binding.checkBox.isChecked = selectedPhotos.contains(photo.id)
            } else {
                binding.selectionOverlay.visibility = android.view.View.GONE
                binding.checkBox.visibility = android.view.View.GONE
            }

            // Listeners
            binding.root.setOnClickListener {
                onPhotoClick(photo)
            }

            binding.root.setOnLongClickListener {
                onPhotoLongClick(photo)
                true
            }
        }
    }

    private class PhotoDiffCallback : DiffUtil.ItemCallback<PhotoEntity>() {
        override fun areItemsTheSame(oldItem: PhotoEntity, newItem: PhotoEntity): Boolean {
            return oldItem.id == newItem.id
        }

        override fun areContentsTheSame(oldItem: PhotoEntity, newItem: PhotoEntity): Boolean {
            return oldItem == newItem
        }
    }
}