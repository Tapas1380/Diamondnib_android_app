<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Comment extends Model
{
    use HasFactory;

    protected $table = 'tbl_comment';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'comment_id' => 'integer',
        'user_id' => 'integer',
        'threads_id' => 'integer',
        'comment' => 'string',
        'status' => 'integer',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
