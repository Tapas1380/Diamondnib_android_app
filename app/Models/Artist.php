<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;

class Artist extends Authenticatable
{
    use HasFactory;

    protected $table = 'tbl_artist';
    protected $guarded = array();

    protected $hidden = [
        'password',
    ];

    protected $casts = [
        'id' => 'integer',
        'user_name' => 'string',
        'password' => 'string',
        'image' => 'string',
        'bio' => 'string',
        'instagram_url' => 'string',
        'facebook_url' => 'string',
        'status' => 'integer',
    ];
}
