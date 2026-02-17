<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Content_Section extends Model
{
    use HasFactory;

    protected $table = 'tbl_content_section';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'section_type' => 'integer',
        'is_home_screen' => 'integer',
        'top_category_id' => 'integer',
        'content_type' => 'integer',
        'title' => 'string',
        'short_title' => 'string',
        'category_id' => 'integer',
        'language_id' => 'integer',
        'artist_id' => 'integer',
        'order_by_play' => 'integer',
        'order_by_upload' => 'integer',
        'screen_layout' => 'string',
        'no_of_content' => 'integer',
        'view_all' => 'integer',
        'sortable' => 'integer',
        'status' => 'integer',
    ];
}
