<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Follow extends Model
{
    use HasFactory;

    protected $table = 'tbl_follow';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'user_id' => 'integer',
        'artist_id' => 'integer',
        'status' => 'integer',
    ];

    public function artist()
    {
        return $this->belongsTo(Artist::class, 'artist_id');
    }
}
