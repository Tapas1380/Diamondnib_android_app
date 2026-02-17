<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Package extends Model
{
    use HasFactory;

    protected $table = 'tbl_package';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'name' => 'string',
        'image' => 'string',
        'price' => 'integer',
        'coin' => 'integer',
        'android_product_package' => 'string',
        'ios_product_package' => 'string',
        'status' => 'integer',
    ];
}
