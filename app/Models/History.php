<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class History extends Model
{
    use HasFactory;

    protected $table = 'tbl_history';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'content_type' => 'integer',
        'audiobook_type' => 'integer',
        'user_id' => 'integer',
        'content_id' => 'integer',
        'content_episode_id' => 'integer',
        'stop_time' => 'integer',
        'status' => 'integer',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
    public function content()
    {
        return $this->belongsTo(Content::class, 'content_id');
    }
}
