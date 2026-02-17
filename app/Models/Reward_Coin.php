<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Reward_Coin extends Model
{
    use HasFactory;

    protected $table = 'tbl_reward_coin';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'key' => 'string',
        'value' => 'string',
        'type' => 'integer',
    ];
}
