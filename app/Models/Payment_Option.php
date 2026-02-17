<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Payment_Option extends Model
{
    use HasFactory;

    protected $table = 'tbl_payment_option';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'name' => 'string',
        'visibility' => 'string',
        'is_live' => 'string',
        'key_1' => 'string',
        'key_2' => 'string',
        'key_3' => 'string',
    ];
}
