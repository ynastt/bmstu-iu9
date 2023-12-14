package com.example.httpjson

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter
import androidx.appcompat.widget.AppCompatTextView
import android.widget.Toast

class ListAdapte (val context: Context, val list: ArrayList<Music>) : BaseAdapter() {
    override fun getCount(): Int {
        return list.size
    }

    override fun getItem(position: Int): Any {
        return list[position]
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun getView(position: Int, countertView: View?, parent: ViewGroup?): View {

        val view: View = LayoutInflater.from(context).inflate(R.layout.row_layout,parent,false)
        val musicId = view.findViewById(R.id.music_id) as AppCompatTextView
        val url_ = view.findViewById(R.id.music_url) as AppCompatTextView
        val genre = view.findViewById(R.id.music_genre) as AppCompatTextView
        val type = view.findViewById(R.id.music_type) as AppCompatTextView

        musicId.text = list[position].id.toString()
        url_.text = list[position].url
        type.text = list[position].type
        genre.text = list[position].genre

        view.setOnClickListener({
            Toast.makeText(context, "Music list\n" , Toast.LENGTH_SHORT).show()
        })
        return view
    }
}