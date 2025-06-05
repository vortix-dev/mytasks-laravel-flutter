<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class tasks extends Model
{
    use HasFactory;

    protected $fillable = ['task', 'user_id'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
