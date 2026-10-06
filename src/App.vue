<script setup lang="ts">
import { ref } from "vue";
import axios from "axios";

// Define the type for a Todo item based on the database schema
type Todo = {
  id: number;
  title: string;
  completed: boolean;
  created_at: string;
};

// Import base url from .env file
const baseURL = import.meta.env.VITE_BASE_URL;
console.log({ baseURL });

// Create a reactive reference to hold the list of todos
const todos = ref<Todo[]>([]);
const todoText = ref("");
const edit = ref(false);
const currentTodo = ref<Todo | null>(null);

async function fetchTodos() {
  const res = await axios.get<Todo[]>(`${baseURL}/todos`);
  todos.value = res.data;
}

async function handleSubmitTodo() {
  if (!todoText.value) return;

  if (!edit.value) {
    const res = await axios.post(`${baseURL}/todos`, {
      title: todoText.value,
    });
    fetchTodos();
    todoText.value = "";
  }
  if (edit.value && currentTodo.value) {
    const res = await axios.patch(`${baseURL}/todos/${currentTodo.value.id}`, {
      title: todoText.value,
    });
    fetchTodos();
    todoText.value = "";
    edit.value = false;
    currentTodo.value = null;
  }
}

async function handleDeleteTodo(id: number) {
  const res = await axios.delete(`${baseURL}/todos/${id}`);
  fetchTodos();
}

function handleEditTodo(todo: Todo) {
  edit.value = true;
  currentTodo.value = todo;
  todoText.value = todo.title;
}

function cancelEdit() {
  edit.value = false;
  currentTodo.value = null;
  todoText.value = "";
}

// Fetch the todos when the component is mounted
fetchTodos();
</script>

<template>
  <h1>To Do</h1>
  <input type="text" v-model="todoText" placeholder="Add a new todo" />
  <button @click="handleSubmitTodo">{{ edit ? "Update" : "Add" }}</button>
  <button v-if="edit" @click="cancelEdit">Cancel</button>
  <div class="todo-wrapper">
    <div v-for="(todo, idx) in todos" :key="todo.id" class="todo-item">
      <span>{{ idx + 1 }}</span>
      <span>📅 {{ new Date(todo.created_at).toLocaleDateString() }}</span>
      <span>⏰ {{ new Date(todo.created_at).toLocaleTimeString() }}</span>
      <span>📰 {{ todo.title }}</span>
      <span @click="handleEditTodo(todo)" class="trash">🖊️</span>
      <span @click="handleDeleteTodo(todo.id)" class="trash">🗑️</span>
    </div>
  </div>
</template>

<style scoped>
@import url("https://fonts.googleapis.com/css2?family=Prompt:ital,wght@0,400;0,700;1,400&display=swap");

* {
  font-family: "Prompt", sans-serif;
}

.todo-wrapper {
  margin-top: 2em;
  display: flex;
  flex-direction: column;
  align-items: start;
  gap: 1em;
}

.todo-item {
  display: flex;
  gap: 0.5em;
  align-items: center;
  border: 1px solid #ccc;
  padding: 0.5em;
  border-radius: 0.5em;
}

.todo-item:hover {
  background-color: #ccc;
}

.trash {
  cursor: pointer;
}
</style>
