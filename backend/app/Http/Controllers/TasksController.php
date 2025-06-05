<?php
namespace App\Http\Controllers;

use App\Models\tasks;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;

class TasksController extends Controller
{
    use AuthorizesRequests;
    public function index()
    {
        $tasks = Auth::user()->tasks; 
        return response()->json([
            'status' => 200,
            'data' => $tasks
        ],200);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'task' => 'required|string|max:255',
        ]);

        $task = tasks::create([
            'task' => $validated['task'],
            'user_id' => Auth::id(),
        ]);

        return response()->json([
            'status' => 200,
            'message' => 'Your task has created with successfully',
            'data' => $task, 
        ],201);
    }

    public function show(tasks $task)
    {
        return response()->json([
            'status' => 200,
            'data' => $task,
        ],200);
    }

    public function update(Request $request,tasks $task)
    {
        $request->validate([
            'task' => 'required|string|max:255',
        ]);

        if($request->filled('task')){
            $task->task = $request->task;
        }
        $task->save();

        return response()->json([
            'status' => 200,
            'message' => 'Your task has updated successfully'
        ], 200);
    }


    public function destroy(tasks $task)
    {
        $task->delete();

        return response()->json([
            'status' => 200,
            'message' => 'Task deleted successfully'
        ],200);
    }
}
