<template>
	<div class="space-y-5">
		<div class="space-y-2">
			<div class="flex items-center space-x-2 text-sm font-medium">
				<span>
					{{ __('Что означает включить в предварительный просмотр?') }}
				</span>
			</div>
			<div class="mb-1 text-xs leading-5 text-gray-600">
				{{
					__(
						'Если для урока включена опция "Включить в предварительный просмотр", то урок будет доступен и для незарегистрированных пользователей.',
					)
				}}
			</div>
		</div>

		<div class="space-y-2">
			<div
				class="flex items-center space-x-2 text-sm font-medium cursor-pointer"
				@click="openHelpDialog('quiz')"
			>
				<span>
					{{ __('Как добавить викторину?') }}
				</span>
				<Info class="w-3 h-3 text-gray-700" />
			</div>
			<div class="mb-1 text-xs leading-5 text-gray-600">
				{{
					__(
						'Нажмите на значок добавления в редакторе и выберите "Викторина" из меню. Откроется диалоговое окно, где вы можете выбрать викторину из списка или создать новую. При выборе опции "Создать новую" вы будете перенаправлены на страницу создания викторины.',
					)
				}}
			</div>
		</div>

		<div class="space-y-2">
			<div
				class="flex space-x-2 text-sm font-medium cursor-pointer"
				@click="openHelpDialog('upload')"
			>
				<span class="leading-5">
					{{ __(contentMap['upload']) }}
				</span>
				<Info class="w-3 h-3 text-gray-700" />
			</div>
			<div class="mb-1 text-xs leading-5 text-gray-600">
				{{
					__(
						'Чтобы загрузить изображение, видео, аудио или PDF с вашего компьютера, нажмите на значок добавления и выберите "Загрузить" из меню. Затем выберите файл, который хотите добавить к уроку, и он будет добавлен.',
					)
				}}
			</div>
		</div>

		<div class="space-y-2">
			<div
				class="flex items-center space-x-2 text-sm font-medium cursor-pointer"
				@click="openHelpDialog('youtube')"
			>
				<span>
					{{ __(contentMap['youtube']) }}
				</span>
				<Info class="w-3 h-3 text-gray-700" />
			</div>
			<div class="mb-1 text-xs leading-5 text-gray-600">
				{{ __('Скопируйте URL видео с YouTube и вставьте его в редактор.') }}
			</div>
		</div>
	</div>
	<ExplanationVideos v-model="showExplanation" :title="title" :type="type" />
</template>
<script setup>
import ExplanationVideos from '@/components/Modals/ExplanationVideos.vue'
import { Info } from 'lucide-vue-next'
import { ref } from 'vue'

const showExplanation = ref(false)
const type = ref(null)
const title = ref(null)
const contentMap = {
	quiz: 'How to add a Quiz?',
	upload: 'How to upload content from your system?',
	youtube: 'How to add a YouTube Video?',
}

const openHelpDialog = (contentType) => {
	type.value = contentType
	title.value = contentMap[contentType]
	showExplanation.value = true
}
</script>
