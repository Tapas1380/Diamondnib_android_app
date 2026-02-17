<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class General_Setting extends Model
{
    use HasFactory;

    protected $table = 'tbl_general_setting';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'key' => 'string',
        'value' => 'string',
        'status' => 'integer',
    ];
}
