<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Content_Episode extends Model
{
    use HasFactory;

    protected $table = 'tbl_content_episode';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'content_id' => 'integer',
        'name' => 'string',
        'image' => 'string',
        'description' => 'string',
        'audio_type' => 'integer',
        'audio' => 'string',
        'audio_duration' => 'integer',
        'is_audio_paid' => 'integer',
        'is_audio_coin' => 'integer',
        'total_audio_played' => 'integer',
        'video_type' => 'integer',
        'video' => 'string',
        'video_duration' => 'integer',
        'is_video_paid' => 'integer',
        'total_video_played' => 'integer',
        'book' => 'string',
        'is_book_paid' => 'integer',
        'is_book_coin' => 'integer',
        'total_book_played' => 'integer',
        'sortable' => 'integer',
        'status' => 'integer',
    ];

    public function content()
    {
        return $this->belongsTo(Content::class, 'content_id');
    }
}
