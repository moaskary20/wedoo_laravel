<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    protected $fillable = [
        'customer_id',
        'craftsman_id',
        'task_type_id',
        'title',
        'description',
        'location',
        'governorate',
        'city',
        'district',
        'budget',
        'preferred_date',
        'status',
        'notes',
        'craftsman_status',
    ];

    protected $casts = [
        'preferred_date' => 'datetime',
    ];

    protected static function boot()
    {
        parent::boot();

        // Update craftsman_status when status is updated
        static::updating(function ($order) {
            if ($order->isDirty('status') && !$order->isDirty('craftsman_status')) {
                // Map status to craftsman_status
                $statusMapping = [
                    'pending' => 'awaiting_assignment',
                    'accepted' => 'accepted',
                    'in_progress' => 'in_progress',
                    'completed' => 'completed',
                    'cancelled' => 'rejected',
                    'rejected' => 'rejected',
                ];

                $newStatus = $order->status;
                if (isset($statusMapping[$newStatus])) {
                    $order->craftsman_status = $statusMapping[$newStatus];
                }
            }
        });

        // Also handle saved event to ensure craftsman_status is synced
        static::saved(function ($order) {
            // If status was updated but craftsman_status wasn't, sync them
            if ($order->wasChanged('status') && !$order->wasChanged('craftsman_status')) {
                $statusMapping = [
                    'pending' => 'awaiting_assignment',
                    'accepted' => 'accepted',
                    'in_progress' => 'in_progress',
                    'completed' => 'completed',
                    'cancelled' => 'rejected',
                    'rejected' => 'rejected',
                ];

                $newStatus = $order->status;
                if (isset($statusMapping[$newStatus]) && $order->craftsman_status !== $statusMapping[$newStatus]) {
                    $order->craftsman_status = $statusMapping[$newStatus];
                    $order->saveQuietly(); // Save without triggering events
                }
            }
        });
    }

    // Relationships
    public function customer()
    {
        return $this->belongsTo(User::class, 'customer_id');
    }

    public function craftsman()
    {
        return $this->belongsTo(User::class, 'craftsman_id');
    }

    public function taskType()
    {
        return $this->belongsTo(TaskType::class);
    }
}
