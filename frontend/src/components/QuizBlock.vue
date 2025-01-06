<template>
	<Quiz v-if="user.data" :quizName="quiz"></Quiz>
	<div v-else class="py-20 text-center border rounded-md">
		<div>
			{{ __('Пожалуйста, войдите, чтобы получить доступ к викторине.') }}
		</div>
		<Button @click="redirectToLogin()" class="mt-2">
			<span>
				{{ __('Войти') }}
			</span>
		</Button>
	</div>
</template>
<script setup>
import Quiz from '@/components/Quiz.vue'
import { Button } from 'frappe-ui'
import { inject } from 'vue'

const user = inject('$user')
const props = defineProps({
	quiz: {
		type: String,
		required: true,
	},
})

const redirectToLogin = () => {
	window.location.href = `/login`
}
</script>
