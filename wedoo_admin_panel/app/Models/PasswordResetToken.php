<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PasswordResetToken extends Model
{
    // Laravel default password_reset_tokens table uses 'email' as primary key
    protected $primaryKey = 'email';
    public $incrementing = false;
    protected $keyType = 'string';
    
    protected $fillable = [
        'email',
        'token',
        'expires_at',
    ];

    protected $casts = [
        'expires_at' => 'datetime',
    ];
}
