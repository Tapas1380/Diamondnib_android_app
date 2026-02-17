<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Banner extends Model
{
    use HasFactory;

    protected $table = 'tbl_banner';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'section_type' => 'integer',
        'is_home_screen' => 'integer',
        'top_category_id' => 'integer',
        'content_type' => 'integer',
        'content_id' => 'integer',
        'status' => 'integer',
    ];

    public function content()
    {
        return $this->belongsTo(Content::class, 'content_id');
    }
}
