<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Threads extends Model
{
    use HasFactory;

    protected $table = 'tbl_threads';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'user_type' => 'integer',
        'user_id' => 'integer',
        'description' => 'string',
        'image' => 'string',
        'total_like	' => 'integer',
        'status' => 'integer',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
    public function artist()
    {
        return $this->belongsTo(Artist::class, 'user_id');
    }
}
