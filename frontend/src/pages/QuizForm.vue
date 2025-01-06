<template>
	<header
		class="sticky top-0 z-10 flex items-center justify-between border-b bg-white px-3 py-2.5 sm:px-5"
	>
		<Breadcrumbs :items="breadcrumbs" />
		<div class="space-x-2">
			<router-link
				v-if="quizDetails.data?.name"
				:to="{
					name: 'QuizPage',
					params: {
						quizID: quizDetails.data.name,
					},
				}"
			>
				<Button>
					{{ __('Открыть') }}
				</Button>
			</router-link>
			<router-link
				v-if="quizDetails.data?.name"
				:to="{
					name: 'QuizSubmissionList',
					params: {
						quizID: quizDetails.data.name,
					},
				}"
			>
				<Button>
					{{ __('Список отправленных') }}
				</Button>
			</router-link>
			<Button variant="solid" @click="submitQuiz()">
				{{ __('Сохранить') }}
			</Button>
		</div>
	</header>
	<div class="w-3/4 py-5 mx-auto">
		<!-- Details -->
		<div class="mb-8">
			<div class="mb-4 font-semibold">
				{{ __('Детали') }}
			</div>
			<FormControl
				v-model="quiz.title"
				:label="
					quizDetails.data?.name
						? __('Название')
						: __('Введите название и сохраните тест, чтобы продолжить')
				"
				:required="true"
			/>
			<div v-if="quizDetails.data?.name">
				<div class="grid grid-cols-2 gap-5 mt-4 mb-8">
					<FormControl
						type="number"
						v-model="quiz.max_attempts"
						:label="__('Максимум попыток')"
					/>
					<FormControl
						type="number"
						v-model="quiz.duration"
						:label="__('Длительность (в минутах)')"
					/>
					<FormControl
						v-model="quiz.total_marks"
						:label="__('Общий балл')"
						disabled
					/>
					<FormControl
						v-model="quiz.passing_percentage"
						:label="__('Проходной процент')"
					/>
				</div>

				<!-- Settings -->
				<div class="mb-8">
					<div class="mb-4 font-semibold">
						{{ __('Настройки') }}
					</div>
					<div class="grid grid-cols-3 gap-5 my-4">
						<FormControl
							v-model="quiz.show_answers"
							type="checkbox"
							:label="__('Показывать ответы')"
						/>
						<FormControl
							v-model="quiz.show_submission_history"
							type="checkbox"
							:label="__('Показывать историю отправок')"
						/>
					</div>
				</div>

				<div class="mb-8">
					<div class="mb-4 font-semibold">
						{{ __('Настройки перемешивания') }}
					</div>
					<div class="grid grid-cols-3">
						<FormControl
							v-model="quiz.shuffle_questions"
							type="checkbox"
							:label="__('Перемешивать вопросы')"
						/>
						<FormControl
							v-if="quiz.shuffle_questions"
							v-model="quiz.limit_questions_to"
							:label="__('Ограничить количество вопросов')"
						/>
					</div>
				</div>

				<!-- Questions -->
				<div>
					<div class="flex items-center justify-between mb-4">
						<div class="font-semibold">
							{{ __('Вопросы') }}
						</div>
						<Button @click="openQuestionModal()">
							<template #prefix>
								<Plus class="w-4 h-4" />
							</template>
							{{ __('Новый вопрос') }}
						</Button>
					</div>
					<ListView
						:columns="questionColumns"
						:rows="quiz.questions"
						row-key="name"
						:options="{
							showTooltip: false,
						}"
					>
						<ListHeader
							class="grid items-center p-2 mb-2 space-x-4 bg-gray-100 rounded"
						>
							<ListHeaderItem :item="item" v-for="item in questionColumns" />
						</ListHeader>
						<ListRows>
							<ListRow
								:row="row"
								v-slot="{ idx, column, item }"
								v-for="row in quiz.questions"
								@click="openQuestionModal(row)"
								class="cursor-pointer"
							>
								<ListRowItem :item="item">
									<div
										v-if="column.key == 'question_detail'"
										class="h-4 text-xs truncate"
										v-html="item"
									></div>
									<div v-else class="text-xs">
										{{ item }}
									</div>
								</ListRowItem>
							</ListRow>
						</ListRows>
						<ListSelectBanner>
							<template #actions="{ unselectAll, selections }">
								<div class="flex gap-2">
									<Button
										variant="ghost"
										@click="deleteQuestions(selections, unselectAll)"
									>
										<Trash2 class="h-4 w-4 stroke-1.5" />
									</Button>
								</div>
							</template>
						</ListSelectBanner>
					</ListView>
				</div>
			</div>
		</div>
	</div>
	<Question
		v-model="showQuestionModal"
		:questionDetail="currentQuestion"
		v-model:quiz="quizDetails"
		:title="
			currentQuestion.question
				? __('Редактировать вопрос')
				: __('Добавить новый вопрос')
		"
	/>
</template>
<script setup>
import Question from '@/components/Modals/Question.vue'
import { showToast, updateDocumentTitle } from '@/utils'
import {
	Breadcrumbs,
	Button,
	createResource,
	FormControl,
	ListHeader,
	ListHeaderItem,
	ListRow,
	ListRowItem,
	ListRows,
	ListSelectBanner,
	ListView,
} from 'frappe-ui'
import { Plus, Trash2 } from 'lucide-vue-next'
import {
	computed,
	inject,
	onBeforeUnmount,
	onMounted,
	reactive,
	ref,
	watch,
} from 'vue'
import { useRouter } from 'vue-router'

const showQuestionModal = ref(false)
const currentQuestion = reactive({
	question: '',
	marks: 0,
	name: '',
})
const user = inject('$user')
const router = useRouter()

const props = defineProps({
	quizID: {
		type: String,
		required: true,
	},
})

const quiz = reactive({
	title: '',
	total_marks: 0,
	passing_percentage: 0,
	max_attempts: 0,
	duration: 0,
	limit_questions_to: 0,
	show_answers: true,
	show_submission_history: false,
	shuffle_questions: false,
	questions: [],
})

onMounted(() => {
	if (
		props.quizID == 'new' &&
		!user.data?.is_moderator &&
		!user.data?.is_instructor
	) {
		router.push({ name: 'Courses' })
	}
	if (props.quizID !== 'new') {
		quizDetails.reload()
	}
	window.addEventListener('keydown', keyboardShortcut)
})

const keyboardShortcut = (e) => {
	if (e.key === 's' && (e.ctrlKey || e.metaKey)) {
		submitQuiz()
		e.preventDefault()
	}
}

onBeforeUnmount(() => {
	window.removeEventListener('keydown', keyboardShortcut)
})

watch(
	() => props.quizID !== 'new',
	(newVal) => {
		if (newVal) {
			quizDetails.reload()
		}
	},
)

const quizDetails = createResource({
	url: 'frappe.client.get',
	makeParams(values) {
		return { doctype: 'LMS Quiz', name: props.quizID }
	},
	auto: false,
	onSuccess(data) {
		Object.keys(data).forEach((key) => {
			if (Object.hasOwn(quiz, key)) quiz[key] = data[key]
		})

		let checkboxes = [
			'show_answers',
			'show_submission_history',
			'shuffle_questions',
		]
		for (let idx in checkboxes) {
			let key = checkboxes[idx]
			quiz[key] = quiz[key] ? true : false
		}
	},
})

const quizCreate = createResource({
	url: 'frappe.client.insert',
	auto: false,
	makeParams(values) {
		return {
			doc: {
				doctype: 'LMS Quiz',
				...quiz,
			},
		}
	},
})

const quizUpdate = createResource({
	url: 'frappe.client.set_value',
	auto: false,
	makeParams(values) {
		return {
			doctype: 'LMS Quiz',
			name: values.quizID,
			fieldname: {
				total_marks: calculateTotalMarks(),
				...quiz,
			},
		}
	},
})
const submitQuiz = () => {
	if (quizDetails.data?.name) updateQuiz()
	else createQuiz()
}

const createQuiz = () => {
	quizCreate.submit(
		{},
		{
			onSuccess(data) {
				showToast('Успех', 'Тест успешно создан', 'check')
				router.push({
					name: 'QuizForm',
					params: { quizID: data.name },
				})
			},
			onError(err) {
				showToast('Ошибка', err.messages?.[0] || err, 'x')
			},
		},
	)
}

const updateQuiz = () => {
	quizUpdate.submit(
		{ quizID: quizDetails.data?.name },
		{
			onSuccess(data) {
				quiz.total_marks = data.total_marks
				showToast('Успех', 'Тест успешно обновлен', 'check')
			},
			onError(err) {
				showToast('Ошибка', err.messages?.[0] || err, 'x')
			},
		},
	)
}

const calculateTotalMarks = () => {
	let totalMarks = 0
	if (quiz.limit_questions_to && quiz.questions.length > 0)
		return quiz.questions[0].marks * quiz.limit_questions_to
	quiz.questions.forEach((question) => {
		totalMarks += question.marks
	})
	return totalMarks
}

const questionColumns = computed(() => {
	return [
		{
			label: 'ID',
			key: 'question',
			width: '10rem',
		},
		{
			label: 'Вопрос',
			key: 'question_detail',
			width: '40rem',
		},
		{
			label: 'Баллы',
			key: 'marks',
			width: '5rem',
		},
	]
})

const openQuestionModal = (question = null) => {
	if (question) {
		currentQuestion.question = question.question
		currentQuestion.marks = question.marks
		currentQuestion.name = question.name
	} else {
		currentQuestion.question = ''
		currentQuestion.marks = 0
		currentQuestion.name = ''
	}
	showQuestionModal.value = true
}

const deleteQuestionResource = createResource({
	url: 'lms.lms.api.delete_documents',
	makeParams(values) {
		return {
			doctype: 'LMS Quiz Question',
			documents: values.questions,
		}
	},
})

const deleteQuestions = (selections, unselectAll) => {
	deleteQuestionResource.submit(
		{
			questions: Array.from(selections),
		},
		{
			onSuccess() {
				showToast('Успех', 'Вопросы успешно удалены', 'check')
				quizDetails.reload()
				unselectAll()
			},
		},
	)
}

const breadcrumbs = computed(() => {
	let crumbs = [
		{
			label: 'Тесты',
			route: {
				name: 'Quizzes',
			},
		},
	]
	crumbs.push({
		label: props.quizID == 'new' ? 'Новый тест' : quizDetails.data?.title,
		route: { name: 'QuizForm', params: { quizID: props.quizID } },
	})
	return crumbs
})

const pageMeta = computed(() => {
	return {
		title: props.quizID == 'new' ? 'Новый тест' : quizDetails.data?.title,
		description: 'Форма для создания и редактирования тестов',
	}
})

updateDocumentTitle(pageMeta)
