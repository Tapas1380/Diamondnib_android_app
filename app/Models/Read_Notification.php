<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Read_Notification extends Model
{
    use HasFactory;

    protected $table = 'tbl_read_notification';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'user_id' => 'integer',
        'notification_id' => 'integer',
        'status' => 'integer',
    ];
}
