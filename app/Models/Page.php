<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Page extends Model
{
    use HasFactory;

    protected $table = 'tbl_page';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'page_name' => 'string',
        'title' => 'string',
        'description' => 'string',
        'icon' => 'string',
        'status' => 'integer',
    ];
}
