<template>
	<Dialog
		v-model="show"
		:options="{
			size: 'xl',
		}"
	>
		<template #body>
			<div class="p-5 space-y-4">
				<div v-if="type == 'quiz'" class="text-lg font-semibold">
					{{ __('Добавить тест к вашему уроку') }}
				</div>
				<div v-else class="text-lg font-semibold">
					{{ __('Добавить задание к вашему уроку') }}
				</div>
				<div>
					<Link
						v-if="type == 'quiz'"
						v-model="quiz"
						doctype="LMS Quiz"
						:label="__('Выберите тест')"
						:onCreate="(value, close) => redirectToForm()"
					/>
					<Link
						v-else
						v-model="assignment"
						doctype="LMS Assignment"
						:label="__('Выберите задание')"
						:onCreate="(value, close) => redirectToForm()"
					/>
				</div>
				<div class="flex justify-end space-x-2">
					<Button variant="solid" @click="addAssessment()">
						{{ __('Сохранить') }}
					</Button>
				</div>
			</div>
		</template>
	</Dialog>
</template>
<script setup>
import Link from '@/components/Controls/Link.vue'
import { Button, Dialog } from 'frappe-ui'
import { nextTick, onMounted, ref } from 'vue'

const show = ref(false)
const quiz = ref(null)
const assignment = ref(null)

const props = defineProps({
	type: {
		type: String,
		required: true,
	},
	onAddition: {
		type: Function,
		required: true,
	},
})

onMounted(async () => {
	await nextTick()
	show.value = true
})

const addAssessment = () => {
	props.onAddition(props.type == 'quiz' ? quiz.value : assignment.value)
	show.value = false
}

const redirectToForm = () => {
	if (props.type == 'quiz') window.open('/lms/quizzes/new', '_blank')
	else window.open('/lms/assignments/new', '_blank')
}
</script>
