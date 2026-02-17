<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Music extends Model
{
    use HasFactory;

    protected $table = 'tbl_music';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'artist_id' => 'integer',
        'category_id' => 'integer',
        'language_id' => 'integer',
        'title' => 'string',
        'portrait_img' => 'string',
        'landscape_img' => 'string',
        'description' => 'string',
        'music_upload_type' => 'string',
        'music' => 'string',
        'music_duration' => 'integer',
        'total_played' => 'integer',
        'status' => 'integer',
    ];

    public function artist()
    {
        return $this->belongsTo(Artist::class, 'artist_id');
    }
    public function category()
    {
        return $this->belongsTo(Category::class, 'category_id');
    }
    public function language()
    {
        return $this->belongsTo(Language::class, 'language_id');
    }
}
