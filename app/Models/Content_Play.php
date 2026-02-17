<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Content_Play extends Model
{
    use HasFactory;

    protected $table = 'tbl_content_play';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'content_type' => 'integer',
        'audiobook_type' => 'integer',
        'user_id' => 'integer',
        'content_id' => 'integer',
        'content_episode_id' => 'integer',
        'status' => 'integer',
    ];
}
