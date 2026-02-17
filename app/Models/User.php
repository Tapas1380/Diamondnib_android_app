<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;

class User extends Authenticatable
{
    use HasFactory;

    protected $table = 'tbl_user';
    protected $guarded = array();

    protected $hidden = [
        'password',
    ];

    protected $casts = [
        'id' => 'integer',
        'user_name' => 'string',
        'full_name' => 'string',
        'email' => 'string',
        'password' => 'string',
        'mobile_number' => 'string',
        'image' => 'string',
        'type' => 'integer',
        'bio' => 'string',
        'wallet_coin' => 'integer',
        'device_type' => 'integer',
        'device_token' => 'string',
        'status' => 'integer',
    ];
}
