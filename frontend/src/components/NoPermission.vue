<template>
	<div class="w-1/3 mx-auto my-32 border rounded-md">
		<div class="px-5 py-3 font-medium border-b">
			<span
				class="inline-flex items-center before:bg-red-600 before:w-2 before:h-2 before:rounded-md before:mr-2"
			></span>
			{{ __('Нет доступа') }}
		</div>
		<div v-if="user.data" class="px-5 py-3">
			<div>
				{{ __('У вас нет доступа к этой странице.') }}
			</div>
			<router-link
				:to="{
					name: 'Courses',
				}"
			>
				<Button variant="solid" class="mt-2">
					{{ __('Посмотреть курсы') }}
				</Button>
			</router-link>
		</div>
		<div class="px-5 py-3">
			<div>
				{{ __('Пожалуйста, войдите, чтобы получить доступ к этой странице.') }}
			</div>
			<Button @click="redirectToLogin()" class="mt-4">
				{{ __('Войти') }}
			</Button>
		</div>
	</div>
</template>
<script setup>
import { Button } from 'frappe-ui'
import { inject } from 'vue'

const user = inject('$user')

const redirectToLogin = () => {
	window.location.href = '/login'
}
</script>
