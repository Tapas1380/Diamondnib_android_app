<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Wallet_Transaction extends Model
{
    use HasFactory;

    protected $table = 'tbl_wallet_transaction';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'user_id' => 'integer',
        'content_type' => 'integer',
        'audiobook_type' => 'integer',
        'content_id' => 'integer',
        'content_episode_id' => 'integer',
        'coin' => 'integer',
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
    public function episode()
    {
        return $this->belongsTo(Content_Episode::class, 'content_episode_id');
    }
}
